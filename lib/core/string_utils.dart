import 'dart:convert';

import 'package:enough_mail/enough_mail.dart';

import '../settings/settings.dart';

extension StringUtils on String {
  String get sender => _extractSender(this);
  String get email => _extractEmail(this);
  String get noLinebreak => _noLinebreak(this);
  String get stripSignature => _stripSignature(this);
  String get stripQuote => _stripQuote(this);
  String get stripMultiEmptyLine => _stripMultiEmptyLine(this);
  String get stripUuencode => _stripUuencode(this);
  String get stripHtmlTag => _stripHtmlTag(this);
  String get stripUnicodeEmojiModifier => _stripUnicodeEmojiModifier(this);
  String get stripCustomPattern => _stripCustomPattern(this);

  bool get containsUuencode => _containsUuencode(this);

  String decodeText(String charset) {
    try {
      var re = RegExp(r'=\?.+?\?=');
      if (contains(re)) {
        int start = 0;
        int end = 0;
        var text = this;
        do {
          start = text.indexOf(r'=?', end);
          end = start == -1 ? -1 : text.indexOf(r'?=', start) + 1;
          if (start != -1 && end != -1) {
            var replace =
                text.substring(start, end).replaceAll(RegExp(r'\s'), '');
            text = text.replaceRange(start, end, replace);
          }
        } while (start != -1 && end != -1);
        return MailCodec.decodeHeader(text)!;
      } else if (charset != '') {
        return Charset.decode(latin1.encode(this), charset);
      } else {
        return this;
      }
    } catch (e) {
      return this;
    }
  }

  String _extractSender(String from) {
    var re = RegExp(r'^(.*)(?:[_ ])<(.*)>$');
    var match = re.firstMatch(from);
    var sender = match?.group(1) ?? from;
    re = RegExp('"([^"]*(?:.[^"]*)*)"');
    match = re.firstMatch(sender);
    sender = match?.group(1) ?? sender;
    return sender;
  }

  String _extractEmail(String from) {
    var re = RegExp(r'^(.*)(?:[_ ])<(.*)>$');
    var match = re.firstMatch(from);
    return match?.group(2) ?? from;
  }

  String _noLinebreak(String text) {
    var re = RegExp(r'(\n\s?){3}');
    text = text.trim();
    while (text.contains(re)) {
      text = text.replaceAll(re, '\n\n');
    }
    text = text.replaceAll('\n\n', '⤶ ');
    text = text.replaceAll('\n', '⤶ ');
    return text;
  }

  String stripSameContent(String text) {
    if (!Settings.stripSameContent.val) return this;
    var esc = RegExp.escape(text);
    var re = RegExp('^$esc\$', multiLine: true);
    return replaceAll(re, '');
  }

  String _stripSignature(String text) {
    for (var re in Settings.stripSignature.val) {
      int start = 0;
      int? end = 0;
      re = '^.*$re';
      do {
        start = text.indexOf(RegExp(re, multiLine: true));
        if (start != -1) {
          end = text.indexOf(RegExp(r'\n\s?\n'), start);
          end = end == -1 ? null : end + 1;
          text = text.replaceRange(start, end, '');
          // if (end == -1) {
          //   text = text.substring(0, start);
          // } else {
          //   text = text.substring(0, start) + text.substring(end + 1);
          // }
        }
      } while (start != -1);
    }
    return text;
  }

  String _stripQuote(String text) {
    if (!Settings.stripQuote.val) return text;

    int start = 0;
    int end = 0;
    do {
      start = text.indexOf(RegExp(r'^>.*$', multiLine: true));
      if (start != -1) {
        // end = text.indexOf(RegExp(r'\n\s?\n'), start + 1);
        end = text.indexOf(
            RegExp(r'\n([^>].*|\s?)$', multiLine: true), start + 1);
        if (start > 0) {
          start = text.lastIndexOf(RegExp(r'^.*?', multiLine: true), start - 1);
        }
        if (end == -1) {
          text = text.substring(0, start);
        } else {
          text = text.substring(0, start) + text.substring(end + 1);
        }
      }
    } while (start != -1);
    return text;
  }

  String _stripMultiEmptyLine(String text) {
    if (!Settings.stripMultiEmptyLine.val) return text;

    var re = RegExp(r'(\n\s?){3}');
    while (text.contains(re)) {
      text = text.replaceAll(re, '\n\n');
    }
    return text;
  }

  String _stripCustomPattern(String text) {
    for (var re in Settings.stripCustomPattern.val) {
      int start = 0;
      int? end = 0;
      re = '^.*$re';
      do {
        start = text.indexOf(RegExp(re, multiLine: true));
        if (start != -1) {
          end = text.indexOf(RegExp(r'\n'), start);
          end = end == -1 ? null : end + 1;
          text = text.replaceRange(start, end, '');
          // start = text.lastIndexOf(RegExp(r'\n'), start);
          // if (end == -1) {
          //   text = text.substring(0, start);
          // } else {
          //   text = text.substring(0, start) + text.substring(end + 1);
          // }
        }
      } while (start != -1);
    }
    return text;
  }

  String _stripUuencode(String text) {
    int start = 0;
    int end = 0;
    var re = RegExp(r'\nbegin\s[0-7]{3}\s.+\n');
    start = text.indexOf(re);
    if (start != -1) {
      // end = text.indexOf(RegExp(r'\n(`|\s)?\nend(\n)?'), start);
      // text = text.substring(0, start) + text.substring(end + 6);
      end = text.indexOf(RegExp(r'\nend\s?(\n|$)'), start);
      text = text.replaceRange(start, end == -1 ? null : end + 4, '');
    }
    return text;
  }

  bool _containsUuencode(String text) {
    var re = RegExp(r'\nbegin\s[0-7]{3}\s.+\n');
    return text.contains(re);
  }

  String _stripHtmlTag(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
  }

  String _stripUnicodeEmojiModifier(String text) {
    if (!Settings.stripUnicodeEmojiModifier.val) return text;

    return text
        .replaceAll(RegExp(r'(\ufe0f\u20e3|\u20e3)', unicode: true), ' ')
        .replaceAll(RegExp(r'\ufe0f', unicode: true), '')
        .replaceAll(RegExp(r'\ud83c\udffb', unicode: true), '');
  }
}
