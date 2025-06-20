import 'package:markdown/markdown.dart' as md;

/// A custom Markdown block syntax for alerts that are
/// opened and closed with `:::`.
///
/// Example:
///
/// ```md
/// :::important The title of my alert
/// The content of my alert.
/// :::
/// ```
///
/// This renders as HTML similar to:
/// ```html
/// <aside class="alert important">
///   <div class="alert-header">
///     <span class="material-symbols" aria-hidden="true">important_icon</span>
///     <span>The title of my alert</span>
///   </div>
///   <div class="alert-content">
///     <p>The content of my alert.</p>
///   </div>
/// </aside>
/// ```
class AlertBlockSyntax extends md.BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^:::([a-zA-Z]+)(?:\s+(.*))?\s*$');

  const AlertBlockSyntax();

  @override
  bool canParse(md.BlockParser parser) {
    return pattern.hasMatch(parser.current.content);
  }

  @override
  md.Node? parse(md.BlockParser parser) {
    final match = pattern.firstMatch(parser.current.content);
    if (match == null) return null;

    final alertType = match.group(1)!;
    final title = match.group(2)?.trim();

    // Advance past the opening line
    parser.advance();

    // Collect content lines until we find the closing :::
    final contentLines = <String>[];
    while (!parser.isDone) {
      final line = parser.current.content;
      if (line.trim() == ':::') {
        parser.advance(); // Consume the closing line
        break;
      }
      contentLines.add(line);
      parser.advance();
    }

    // Parse the content as Markdown
    final contentMarkdown = contentLines.join('\n');
    final contentDocument = md.Document(
      extensionSet: md.ExtensionSet.gitHubWeb,
    );
    final contentNodes = contentDocument.parseLines(
      contentMarkdown.split('\n'),
    );

    // Create the alert structure
    final alertElement = md.Element('aside', []);
    alertElement.attributes['class'] = 'alert $alertType';

    // Create header if title is provided
    if (title != null && title.isNotEmpty) {
      final headerElement = md.Element('div', []);
      headerElement.attributes['class'] = 'alert-header';

      // Add icon
      final iconElement = md.Element('span', []);
      iconElement.attributes['class'] = 'material-symbols';
      iconElement.attributes['aria-hidden'] = 'true';
      iconElement.children!.add(md.Text(_getIconForAlertType(alertType)));
      headerElement.children!.add(iconElement);

      // Add title
      final titleElement = md.Element('span', []);
      titleElement.children!.add(md.Text(title));
      headerElement.children!.add(titleElement);

      alertElement.children!.add(headerElement);
    }

    // Create content div
    final contentElement = md.Element('div', []);
    contentElement.attributes['class'] = 'alert-content';
    contentElement.children!.addAll(contentNodes);
    alertElement.children!.add(contentElement);

    return alertElement;
  }

  /// Returns the appropriate icon name for the given alert type.
  String _getIconForAlertType(String alertType) =>
      switch (alertType.toLowerCase()) {
        'note' => 'info',
        'tip' => 'lightbulb',
        'important' => 'priority_high',
        'warning' => 'warning',
        'caution' => 'error',
        _ => 'info',
      };
}
