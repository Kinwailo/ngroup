import 'dart:convert';

import 'post_controller.dart';
import '/core/adaptive.dart';
import '/core/datetime_utils.dart';
import '/core/string_utils.dart';

class PostExport {
  static const exportBegin = r'''<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>$title$</title>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    background: black;
    width: 600px;
    margin: auto;
}

#title {
    background: rgb(0, 72, 72);
    font-size: 18pt;
    padding: 8px;
    margin-bottom: 8px;
}

#logo {
    vertical-align: top;
    margin-right: 8px;
}

.table {
    margin-bottom: 12px;
    border-spacing: 1;
    border-collapse: collapse;
    overflow: hidden;
}

.table, .quote_content {
    background: rgb(26, 28, 28);
}

.table, .quote, .quote_content {
    border-radius: 8px;
}

.sender {
    color: rgb(64, 196, 255);
}

#title, .datetime, .index, .content, .quote_content {
    color: rgb(197, 232, 240);
}

.heading {
    background: rgb(43, 76, 83);
    padding: 4px 8px 4px 8px;
    font-size: 14pt;
}

.index {
    float: right;
    position: relative;
    right: 8px;
}

.quote {
    background: rgb(69, 90, 100);
    margin: 8px;
    padding: 2px 2px 2px 6px;
    width: fit-content;
    max-width: 584px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.quote_content {
    margin-left: 2px;
    padding: 1px 6px 1px 6px;
}

.content {
    margin: 8px;
}

.reply {
    margin: 2px 0px 2px 0px;
}

.divider {
    width: 96%;
    margin-left: 2%;
    margin-top: 8px;
    margin-bottom: 8px;
    border: 0;
    border-top: 1px solid rgba(64, 64, 64, 0.5);
}

.gallery {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 10px;
  list-style-type: none;
}

.gallery > li {
  flex-basis: content;
}

.gallery li img {
  object-fit: cover;
  max-height: 100px;
  width: auto;
  vertical-align: middle;
  border-radius: 8px;
}
    </style>
</head>
<body>
    <h2 id="title"><img id="logo" src="data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAACxIAAAsSAdLdfvwAAAAZdEVYdFNvZnR3YXJlAHBhaW50Lm5ldCA0LjAuMTM0A1t6AAABsElEQVRYR+2Wv07CUBSH7yNQ3XgAQkQGF8HaQQcfSg0xwcRJkqqT/xYMJhqlPAEstDIw0OvQd2Ho9R64h9xwD5jYUpee5AvLIb97v19pYPnks24O/NuyPXRj23cFRa1/HZfuT8tq3ZhC6FUt7k2tsBvLT7FMgXe5WqXn0HcbVDCy17sSpcezhlo3xgp7TSoY2eLeyu/ORt6eU8HITvtClB7OV97CCr2ICka2+cdKe3P9RChSG7QgfA5Rg9JPBgPp6McDEDXI3jPRjxi3yU4/otWQrX5EqyGrp3+Zxa2y14/IGv5HPyJr+E1/YUP6EW59b1C/HbgRhCyFLthtX4ri5JMMBhLrt4ObJmimwoH9nisq43cyHEisvx7cVeFBo8KB48GzcEavZDiQTP/QjdQqk2FGDaD/xH+ZQdWQin61yqgaQD8eoDJ+Mw6Q+OUD+tUqo2oA/XgAZ9QxDpCafhwZuqhB14/oNaSqH0evQdeP6L+GVPXj6DXo+hG9hsQvH7VqjAznlH6kOOluRj8O1EDpR6CGv+uf/x2f1oOWoR8HajjqP8VUOOB8deK1+vPJhzH2Ax7l+O6Gngt3AAAAAElFTkSuQmCC" alt=""/>$title$</h2>
''';

  static const exportPostBegin = r'''    <div class="table">
        <h2 class="heading">
        <span class="sender">$sender$</span>
        <span class="datetime">$datetime$</span>
        <span class="index">#$index$</span>
        </h2>
''';

  static const exportPostMiddle = r'''        <div class="content">
            <p>$content$</p>
''';

  static const exportPostEnd = r'''        </div>
    </div>
''';

  static const exportQuote = r'''        <div class="quote">
            <span class="sender">$quote_sender$</span>
            <span class="quote_content">$quote_content$</span>
        </div>
''';

  static const exportDivider = r'''        <hr class="divider">
''';

  static const exportGalleryBegin = r'''        <ul class="gallery">
''';

  static const exportGalleryMiddle =
      r'''            <li><img src="data:image/$image_format$;base64, $image_data$" alt=""/></li>
''';

  static const exportGalleryEnd = r'''        </ul>
''';

  static const exportReply = r'''        <div class="reply">
            <span class="sender">$reply_sender$</span>
            <span class="content">$reply_content$</span>
        </div>
''';

  static const exportEnd = r'''</body>
</html>
''';

  static void _exportPost(PostData post, StringBuffer output) {
    output.write(exportPostBegin
        .replaceAll(r'$sender$', post.post.from.sender)
        .replaceAll(r'$datetime$', post.post.dateTime.toLocal().string)
        .replaceAll(r'$index$', '${post.index + 1}'));

    if (post.state.showQuote) {
      output.write(exportQuote
          .replaceAll(r'$quote_sender$', post.parent!.post.from.sender)
          .replaceAll(r'$quote_content$',
              post.parent!.body!.text.replaceAll('\n', ' ')));
    }
    var content = post.body!.text.replaceAll('\n', '<br/>');
    output.write(exportPostMiddle.replaceAll(r'$content$', content));

    if (post.body!.images.isNotEmpty) {
      if (content.isNotEmpty || post.state.showQuote) {
        output.write(exportDivider);
      }
      output.write(exportGalleryBegin);
      for (var image in post.body!.images) {
        var format = '';
        if (image.filename.contains('.')) {
          format = image.filename.split('.').last.toLowerCase();
        }
        if (!['webp', 'png', 'jpg', 'jpeg', 'gif', 'bmp'].contains(format)) {
          continue;
        }
        var data = base64Encode(image.data!);
        output.write(exportGalleryMiddle
            .replaceAll(r'$image_format$', format)
            .replaceAll(r'$image_data$', data));
      }
      output.write(exportGalleryEnd);
    }

    if (post.state.reply.any((e) => e.state.inside)) {
      output.write(exportDivider);
      for (var reply in post.state.reply.where((e) => e.state.inside)) {
        output.write(exportReply
            .replaceAll(r'$reply_sender$', reply.post.from.sender)
            .replaceAll(
                r'$reply_content$', reply.body!.text.replaceAll('\n', ' ')));
      }
    }
    output.write(exportPostEnd);
  }

  static String _export(List<PostData> posts) {
    var output = StringBuffer();
    output.write(
        exportBegin.replaceAll(r'$title$', posts[0].post.subject.noLinebreak));

    if (posts.length == 1) {
      _exportPost(posts.first, output);
    } else {
      for (var p in posts) {
        if (!p.state.inside) _exportPost(p, output);
      }
    }

    output.write(exportEnd);
    return output.toString();
  }

  static Future<void> save(List<PostData> posts) async {
    if (posts.isEmpty) return;
    var output = _export(posts);
    var filename = '${posts[0].post.subject}.html';
    Adaptive.saveText(output, 'Export to HTML', filename, 'text/html');
  }

  // static Future<void> export(List<PostData> posts) async {
  //   if (posts.isEmpty) return;

  //   var output = _export(posts);

  //   var fileName = sanitizeFilename('${posts[0].post.subject}.html');
  //   String? path = await FilePicker.platform
  //       .saveFile(dialogTitle: 'Export to HTML', fileName: fileName);
  //   if (path != null) File(path).writeAsString(output, flush: true);
  // }

  // static Future<void> share(List<PostData> posts) async {
  //   if (posts.isEmpty) return;

  //   var output = _export(posts);

  //   var fileName = sanitizeFilename('${posts[0].post.subject}.html');
  //   var temp = await getTemporaryDirectory();
  //   var file = File('${temp.path}/$fileName');
  //   await file.writeAsString(output, flush: true);
  //   await Share.shareXFiles([XFile(file.path, mimeType: 'text/html')]);
  //   await file.delete();
  // }
}
