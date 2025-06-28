import 'package:html/parser.dart' as html;
import 'package:jaspr_content/jaspr_content.dart';
import 'package:markdown/markdown.dart' as md;

import 'alert_syntax.dart';
import 'attribute_syntax.dart';
import 'definition_list_syntax.dart';

class DashMarkdownParser implements PageParser {
  static final _markdownDocument = md.Document(
    blockSyntaxes: const [
      AttributeBlockSyntax(),
      CustomHtmlSyntax(),
      AlertBlockSyntax(),
      DefinitionListSyntax(),
      md.FootnoteDefSyntax(),
    ],
    extensionSet: md.ExtensionSet.gitHubWeb,
  );

  static final _attributePostProcessor = AttributePostProcessor();

  const DashMarkdownParser();

  @override
  Pattern get pattern => RegExp(r'.*\.md?$');

  @override
  List<Node> parsePage(Page page) {
    final markdownNodes = _markdownDocument.parse(page.content);

    final tempElement = md.Element('temp-dash-document', markdownNodes);
    tempElement.accept(_attributePostProcessor);

    return _buildNodes(tempElement.children ?? []);
  }

  List<Node> _buildNodes(Iterable<md.Node> markdownNodes) {
    final nodes = <Node>[];
    for (final node in markdownNodes) {
      if (node is md.Text) {
        nodes.addAll(
          HtmlParser.buildNodes(html.parseFragment(node.text).nodes),
        );
      } else if (node is md.Element) {
        final nodeChildren = node.children;
        if (node.tag.contains('details')) {
          print(nodeChildren?.length);
          print(nodeChildren);
        }
        final children = nodeChildren != null
            ? _buildNodes(nodeChildren)
            : null;
        nodes.add(
          ElementNode(node.tag, {
            if (node.generatedId case final generatedId?) 'id': generatedId,
            ...node.attributes,
          }, children),
        );
      }
    }
    return nodes;
  }
}
