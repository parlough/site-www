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
  RegExp get pattern => RegExp(r'^:::([a-zA-Z-]+)(?:\s+(.*))?$');

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
    var title = match.group(2)?.trim();

    // Use default title if not provided
    if (title == null || title.isEmpty) {
      title = _getDefaultTitle(alertType);
    }

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
    // Create Line objects from the content
    final childLines = contentLines.map(md.Line.new).toList();

    // Create a new BlockParser with the same document context
    // This preserves link references and other document-level state
    final contentNodes = md.BlockParser(
      childLines,
      parser.document,
    ).parseLines(parentSyntax: this);

    // Create the alert structure
    final alertElement = md.Element('aside', []);
    final alertClass = _getAlertClass(alertType);
    alertElement.attributes['class'] = 'alert $alertType $alertClass';

    // Create header if title is provided
    if (title != null && title.isNotEmpty) {
      final headerElement = md.Element('div', []);
      headerElement.attributes['class'] = 'alert-header';

      // Add icon (except for secondary type)
      if (alertType.toLowerCase() != 'secondary') {
        final iconElement = md.Element('span', [
          md.Text(_getIconForAlertType(alertType)),
        ]);
        iconElement.attributes['class'] = 'material-symbols';
        iconElement.attributes['aria-hidden'] = 'true';
        headerElement.children!.add(iconElement);
      }

      // Add title
      // Parse the title as inline Markdown to support links, emphasis, etc.
      final titleNodes = parser.document.parseInline(title);
      final titleElement = md.Element('span', titleNodes);
      headerElement.children!.add(titleElement);

      alertElement.children!.add(headerElement);
    }

    // Create content div
    final contentElement = md.Element('div', contentNodes);
    contentElement.attributes['class'] = 'alert-content';
    alertElement.children!.add(contentElement);

    return alertElement;
  }

  /// Returns the default title for the given alert type.
  String? _getDefaultTitle(String alertType) =>
      switch (alertType.toLowerCase()) {
        'note' => 'Note',
        'flutter-note' => 'Flutter note',
        'version-note' => 'Version note',
        'tip' => 'Tip',
        'recommend' => 'Recommended',
        'important' => 'Important',
        'warning' => 'Warning',
        'caution' => 'Caution',
        'secondary' || _ => null,
      };

  /// Returns the appropriate CSS class for the given alert type.
  String _getAlertClass(String alertType) => switch (alertType.toLowerCase()) {
    'note' || 'version-note' || 'flutter-note' => 'alert-info',
    'tip' || 'recommend' => 'alert-success',
    'important' => 'alert-important',
    'warning' => 'alert-warning',
    'caution' => 'alert-danger',
    _ => 'alert-secondary',
  };

  /// Returns the appropriate icon name for the given alert type.
  String _getIconForAlertType(String alertType) =>
      switch (alertType.toLowerCase()) {
        'note' => 'info',
        'flutter-note' => 'flutter',
        'version_note' => 'merge_type',
        'tip' => 'lightbulb',
        'recommend' => 'bolt',
        'important' => 'feedback',
        'warning' => 'warning',
        'caution' => 'error',
        _ => 'info',
      };
}
