import 'package:markdown/markdown.dart' as md;

/// A custom Markdown block syntax for definition lists.
///
/// Definition lists are composed of terms and their definitions.
/// Terms are written on their own lines, and definitions are written
/// on the following lines, starting with a colon and a space.
///
/// Example:
/// ```md
/// First Term
/// : This is the definition of the first term.
///
/// Second Term
/// : This is one definition of the second term.
/// : This is another definition of the second term.
/// ```
///
/// This renders as HTML:
/// ```html
/// <dl>
///   <dt>First Term</dt>
///   <dd>This is the definition of the first term.</dd>
///   <dt>Second Term</dt>
///   <dd>This is one definition of the second term.</dd>
///   <dd>This is another definition of the second term.</dd>
/// </dl>
/// ```
class DefinitionListSyntax extends md.BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^\s*:\s+(.*)$');

  const DefinitionListSyntax();

  @override
  bool canParse(md.BlockParser parser) {
    // Check if current line is a definition (starts with ': ')
    if (pattern.hasMatch(parser.current.content)) {
      return true;
    }

    // Check if current line is a term followed by a definition
    if (parser.current.content.trim().isNotEmpty &&
        !parser.current.content.startsWith(' ') &&
        !parser.current.content.startsWith('\t')) {
      // Look ahead to see if next line is a definition
      final nextLine = parser.peek(1);
      if (nextLine != null) {
        return pattern.hasMatch(nextLine.content);
      }
    }

    return false;
  }

  @override
  md.Node? parse(md.BlockParser parser) {
    final dlElement = md.Element('dl', []);

    while (!parser.isDone && _isPartOfDefinitionList(parser)) {
      // Parse term(s)
      while (!parser.isDone &&
          parser.current.content.trim().isNotEmpty &&
          !pattern.hasMatch(parser.current.content)) {
        final termContent = parser.current.content.trim();
        if (termContent.isEmpty) break;

        // Parse the term content as inline Markdown with document context
        final termNodes = parser.document.parseInline(termContent);

        final dtElement = md.Element('dt', []);
        dtElement.children!.addAll(termNodes);
        dlElement.children!.add(dtElement);

        parser.advance();
      }

      // Parse definition(s)
      while (!parser.isDone && pattern.hasMatch(parser.current.content)) {
        final match = pattern.firstMatch(parser.current.content);
        if (match == null) break;

        final definitionContent = match.group(1)!;

        // Collect multi-line definition content
        final definitionLines = <String>[definitionContent];
        parser.advance();

        // Continue collecting lines that are part of this definition
        while (!parser.isDone &&
            !pattern.hasMatch(parser.current.content) &&
            (parser.current.content.trim().isEmpty ||
                parser.current.content.startsWith('  ') ||
                parser.current.content.startsWith('\t'))) {
          if (parser.current.content.trim().isEmpty) {
            // Empty line - check if next line continues the definition
            final nextLine = parser.peek(1);
            if (nextLine != null) {
              if (nextLine.content.startsWith('  ') ||
                  nextLine.content.startsWith('\t') ||
                  pattern.hasMatch(nextLine.content)) {
                definitionLines.add('');
                parser.advance();
                continue;
              }
            }
            break;
          } else {
            // Remove leading indentation (2 spaces or 1 tab)
            var line = parser.current.content;
            if (line.startsWith('  ')) {
              line = line.substring(2);
            } else if (line.startsWith('\t')) {
              line = line.substring(1);
            }
            definitionLines.add(line);
            parser.advance();
          }
        }

        // Parse the definition content as Markdown with document context
        // Create Line objects from the definition content
        final childLines = definitionLines.map(md.Line.new).toList();

        // Create a new BlockParser with the same document context
        // This preserves link references and other document-level state
        final definitionNodes = md.BlockParser(
          childLines,
          parser.document,
        ).parseLines(parentSyntax: this);

        final ddElement = md.Element('dd', []);
        ddElement.children!.addAll(definitionNodes);
        dlElement.children!.add(ddElement);
      }

      // Skip empty lines between definition list items
      while (!parser.isDone && parser.current.content.trim().isEmpty) {
        parser.advance();
      }
    }

    return dlElement.children!.isNotEmpty ? dlElement : null;
  }

  /// Checks if the current position is part of a definition list
  bool _isPartOfDefinitionList(md.BlockParser parser) {
    if (parser.isDone) return false;

    final currentLine = parser.current.content;

    // Current line is a definition
    if (pattern.hasMatch(currentLine)) {
      return true;
    }

    // Current line is a term (non-empty, not indented)
    if (currentLine.trim().isNotEmpty &&
        !currentLine.startsWith(' ') &&
        !currentLine.startsWith('\t')) {
      // Look ahead to see if next line is a definition
      final nextLine = parser.peek(1);
      if (nextLine != null) {
        return pattern.hasMatch(nextLine.content);
      }
    }

    return false;
  }
}
