import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_dartio/google_sign_in_dartio.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/drive/v3.dart';

import '../settings/settings.dart';
import 'google_client_id.dart';

class _GoogleSignInStore extends Store {
  final data = Map<String, String>.from(
      json.decode(utf8.decode(gzip.decode(base64.decode(Settings.auth.val)))));
  void save(Map data) => Settings.auth.val =
      base64.encode(gzip.encode(utf8.encode(json.encode(data))));
  static String get defaultValue =>
      base64.encode(gzip.encode(utf8.encode(json.encode({}))));
  @override
  String? get(String key) => data[key];
  @override
  void set(String key, String value) =>
      save({...data..update(key, (_) => value, ifAbsent: () => value)});
  @override
  void remove(String key) => save({...data..remove(key)});
  @override
  void clearAll() => save({...data..clear()});
}

class GoogleDrive extends ChangeNotifier {
  static const List<String> _scopes = [DriveApi.driveAppdataScope];

  static GoogleDrive? _instance;
  static GoogleDrive get i => _instance ??= GoogleDrive._();
  static String get authDefault => _GoogleSignInStore.defaultValue;

  static String? get _clientId {
    return kIsWeb
        ? clientIdWeb
        : switch (defaultTargetPlatform) {
            TargetPlatform.android || TargetPlatform.fuchsia => null,
            TargetPlatform.iOS || TargetPlatform.macOS => clientIdiOS,
            TargetPlatform.windows || TargetPlatform.linux => clientIdDesktop,
          };
  }

  late final GoogleSignIn _googleSignIn;
  GoogleSignInAccount? _user;
  DriveApi? _driveApi;
  String? _error;
  final _syncing = ValueNotifier(false);

  GoogleSignInAccount? get user => _user;
  String? get error => _error;
  ValueListenable<bool> get syncing => _syncing;

  GoogleDrive._() {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      GoogleSignInDart.register(
        clientId: _clientId!,
        exchangeEndpoint: 'https://auth.kinwailo.workers.dev/',
        store: _GoogleSignInStore(),
      );
    }
    _googleSignIn = GoogleSignIn(clientId: _clientId, scopes: _scopes);
    _googleSignIn.onCurrentUserChanged.listen((account) async {
      _driveApi = null;
      _user = account;
      if (account == null) {
        notifyListeners();
        return;
      }
      bool auth = await checkAccess();
      if (auth) {
        try {
          final client = await _googleSignIn.authenticatedClient();
          _driveApi = DriveApi(client!);
        } catch (e) {
          _error = e.toString();
          auth = false;
        }
      }
      if (!auth) await signOut();
      if (auth) notifyListeners();
    });
  }

  Future<bool> checkAccess() async {
    if (!kIsWeb) return true;
    var auth = await _googleSignIn.canAccessScopes(_scopes);
    try {
      if (!auth) auth = await _googleSignIn.requestScopes(_scopes);
      if (!auth) await _googleSignIn.signOut();
    } catch (_) {
      await _googleSignIn.signOut();
    }
    return auth;
  }

  Future<void> signInSilently() async {
    _googleSignIn.signInSilently();
  }

  Future<void> signIn() async {
    try {
      _error = null;
      await _googleSignIn.signOut();
      await _googleSignIn.signIn();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
  }

  bool get isLoggedIn => user != null;

  Future<String?> _getFileId(String filename) async {
    if (_driveApi == null) return null;
    var fileList = await _driveApi!.files.list(
      q: 'name="$filename"',
      supportsAllDrives: false,
      spaces: 'appDataFolder',
      $fields: 'files(id)',
    );
    var id = fileList.files?.firstOrNull?.id;
    id ??= (await _driveApi!.files
            .create(File(name: filename, parents: ['appDataFolder'])))
        .id;
    return id;
  }

  Future<Map<String, dynamic>?> read(String filename) async {
    if (!isLoggedIn || !await checkAccess()) return null;

    _syncing.value = true;
    try {
      final id = await _getFileId(filename);
      if (_driveApi == null || id == null) return null;

      try {
        final file = await _driveApi!.files
            .get(id, downloadOptions: DownloadOptions.fullMedia) as Media;
        final stream =
            const JsonDecoder().bind(const Utf8Decoder().bind(file.stream));
        return Map<String, dynamic>.from(await stream.first as Map);
      } catch (_) {
        return null;
      }
    } finally {
      _syncing.value = false;
    }
  }

  Future<void> write(String filename, Map<String, dynamic> data) async {
    if (!isLoggedIn || !await checkAccess()) return;

    final id = await _getFileId(filename);
    if (_driveApi == null || id == null) return;
    _syncing.value = true;

    final buffer = utf8.encode(json.encode(data));
    final media = Media(Stream.value(buffer), buffer.length,
        contentType: 'application/json');
    await _driveApi!.files.update(File(), id, uploadMedia: media);
    _syncing.value = false;
  }

  Future<void> delete(String filename) async {
    if (!isLoggedIn || !await checkAccess()) return;

    _syncing.value = false;
    try {
      final id = await _getFileId(filename);
      if (_driveApi == null || id == null) return;
      await _driveApi!.files.delete(id);
    } finally {
      _syncing.value = false;
    }
  }
}
