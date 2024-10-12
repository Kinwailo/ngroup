import 'package:html/dom.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:ngroup/conv/conv.dart';
import 'package:ngroup/core/string_utils.dart';
import 'package:validators/sanitizers.dart';
import 'package:html_unescape/html_unescape.dart';

class HtmlSimplifier {
  static const tags =
      'a,b,big,blockquote,br,caption,center,code,dd,del,div,dl,dt,em,font,'
      'h1,h2 h3,h4,h5,h6,hr,i,img,ins,li,mark,ol,p,pre,q,rp,rt,ruby,'
      's,small,strike,strong,sub,sup,span,table,tbody,td,tfoot,th,thead,tr,u,ul';

  static const attributes = {
    'a': ['href'],
    'img': ['src', 'width', 'height'],
    'td': ['colspan', 'rowspan'],
    'tr': ['colspan', 'rowspan'],
  };

  static const styles =
      'font-style,font-weight,font-size'; //,color,background-color';

  static var pre = false;

  static String simplifyHtml(String html) {
    var doc = htmlparser.HtmlParser(html, parseMeta: false).parseFragment();
    _filterNode(doc);
    // print(doc.outerHtml);
    return doc.outerHtml;
  }

  static String textifyHtml(String html) {
    var doc = htmlparser.HtmlParser(html, parseMeta: false).parseFragment();
    _textNode(doc);
    var text = HtmlUnescape().convert(doc.outerHtml).stripMultiEmptyLine.trim();
    // print(text);
    return text;
  }

  static Map<String, String> _getStyle(String? text) {
    if (text == null) return {};
    return {
      for (var v in rtrim(text, ';').split(';').where((e) => e.contains(':')))
        v.split(':')[0].toLowerCase().trim():
            v.split(':')[1].toLowerCase().trim()
    };
  }

  static void _filterNode(Node node) {
    var nodes = node.nodes.expand(_filterTag).toList();
    node.nodes
      ..clear()
      ..addAll(nodes);
    node.nodes.forEach(_filterNode);
  }

  static List<Node> _filterTag(Node node) {
    if (node is Text) return [node..data = node.data.convUseSetting];
    if (node is Element) {
      var style = node.attributes['style'];
      node.attributes.removeWhere((k, _) =>
          !(attributes[node.localName]?.contains(k.toString()) ?? false));
      if (style != null) {
        var map = _getStyle(style);
        map.removeWhere((k, v) => !styles.split(',').contains(k));
        style = map.keys.map((k) => '$k:${map[k]!}').join(';');
        node.attributes['style'] = style;
        if (style.isEmpty) node.attributes.remove('style');
      }
      if (tags.split(',').contains(node.localName)) return [node];
      return node.nodes.expand(_filterTag).toList();
    }
    return [];
  }

  static void _textNode(Node node) {
    var nodes = node.nodes.expand(_textOnly).toList();
    node.nodes
      ..clear()
      ..addAll(nodes);
    node.nodes.forEach(_textNode);
    pre = false;
  }

  static List<Node> _textOnly(Node node) {
    if (node is Text) {
      var data = node.data.convUseSetting;
      if (pre) return [node..data = data];
      return [node..data = data.replaceAll(RegExp(r'\s+'), ' ').trim()];
    }
    if (node is Element) {
      if (node.localName == 'img') return [Text('${node.attributes['src']} ')];
      if (node.localName == 'br') return [Text('\n')];

      var whiteSpace = _getStyle(node.attributes['style'])['white-space'];
      if (node.localName == 'pre' || whiteSpace == 'pre') pre = true;
      var nodes = node.nodes.expand(_textOnly);

      return [
        ...nodes,
        if (node.localName == 'div' && nodes.isNotEmpty) Text('\n'),
        if (node.localName == 'p') nodes.isEmpty ? Text('\n') : Text('\n\n'),
        if (node.localName == 'a' && nodes.isNotEmpty)
          Text(' ${node.attributes['href']} '),
      ];
    }
    return [];
  }
}
