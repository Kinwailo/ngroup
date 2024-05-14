import 'isar/isar.dart' if (dart.library.html) 'sembast/sembast.dart';
// import 'sembast/sembast.dart';
import 'models.dart';

abstract class AppDatabase {
  AppDatabase._();

  static late AppDatabase? _instance;
  static AppDatabase get get => _instance!;

  static Future<void> init(String path) async {
    _instance = await DatabaseImp.init(path);
  }

  Future<List<Setting>> settingList();

  Future<Setting?> getSetting(String key);

  Future<void> updateSetting(Setting setting);

  Future<int> addServer(String address, int port);

  Future<void> updateServer(Server server);

  Future<Server?> getServer(int id);

  Future<void> deleteServer(int id);

  Stream<List<Server>> serverListStream();

  Future<List<Server>> serverList();

  Future<List<Group>> addGroups(List<Group> groups);

  Future<void> updateGroup(Group group);

  Future<void> updateGroups(List<Group> groups);

  Future<Group?> getGroup(int id);

  Stream<List<Group>> groupListStream({int? serverId});

  Future<List<Group>> groupList({int? serverId});

  Future<void> deleteGroup(int id);

  Future<void> resetGroup(int id);

  Future<void> sweepGroup(int id, int number);

  Stream<dynamic> threadChangeStream(int groupId);

  Future<List<Thread>> threadList(int groupId);

  Future<void> addThreads(List<Thread> threads);

  Future<Thread?> getThread(String messageId);

  Future<List<Thread>> getThreads(List<String> messageIds);

  Future<void> markThreadRead(String threadId, String messageId);

  Future<void> resetAllNewThreads(int groupId);

  Future<void> markAllThreadsRead(int groupId);

  Stream<dynamic> postChangeStream(String threadId);

  Future<List<Post>> postList(String threadId);

  Future<void> addPosts(List<Post> posts);

  Future<void> updatePost(Post post);

  Future<Post?> getPost(String messageId);

  Future<void> resetAllNewPosts(int groupId);

  Future<void> markAllPostsRead(int groupId);
}
