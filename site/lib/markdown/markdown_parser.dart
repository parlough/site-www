import 'dart:convert';

import 'package:html/parser.dart' as html;
import 'package:jaspr_content/jaspr_content.dart';
import 'package:markdown/markdown.dart' as md;

import 'alert_syntax.dart';
import 'attribute_syntax.dart';
import 'definition_list_syntax.dart';
import 'fenced_code_block_syntax.dart';

final md.Document _sharedMarkdownDocument = md.Document(
  blockSyntaxes: const [
    CustomFencedCodeBlockSyntax(),
    AttributeBlockSyntax(),
    AlertBlockSyntax(),
    DefinitionListSyntax(),
    md.HeaderWithIdSyntax(),
    md.TableSyntax(),
    md.FootnoteDefSyntax(),
    CustomHtmlSyntax(),
  ],
  inlineSyntaxes: [
    md.InlineHtmlSyntax(),
  ],
);

String parseMarkdownToHtml(String markdown) {
  final nodes = _sharedMarkdownDocument.parse(markdown);
  final renderer = md.HtmlRenderer();
  return renderer.render(nodes);
}

class DashMarkdownParser implements PageParser {
  static final _attributePostProcessor = AttributePostProcessor();

  const DashMarkdownParser();

  @override
  Pattern get pattern => RegExp(r'.*\.md?$');

  @override
  List<Node> parsePage(Page page) {
    final pageContent = _removeProcessingInstructions(page.content);

    final markdownNodes = _sharedMarkdownDocument.parse(pageContent);

    final tempElement = md.Element('temp-dash-document', markdownNodes);
    tempElement.accept(_attributePostProcessor);

    return _buildNodes(tempElement.children ?? []);
  }

  // TODO(parlough): Remove workaround when processing instructions
  //   stop breaking the HTML syntax.
  static String _removeProcessingInstructions(String content) {
    final lines = const LineSplitter().convert(content.trimRight());
    final filteredLines = <String>[
      for (final line in lines)
        if (!line.contains('<?code-excerpt')) line,
    ];

    return filteredLines.join('\n');
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
