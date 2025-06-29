import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:syntax_highlight_lite/syntax_highlight_lite.dart' hide Color;

/// Custom component for integrating DashCodeBlock with Jaspr Content
class DashCodeBlockComponent implements CustomComponent {
  DashCodeBlockComponent({
    this.grammars = const {},
    this.theme,
  });

  /// Additional grammars for syntax highlighting
  final Map<String, String> grammars;

  /// The highlighting theme
  final HighlighterTheme? theme;

  bool _initialized = false;
  HighlighterTheme? _defaultTheme;

  @override
  Component? create(Node node, NodesBuilder builder) {
    if (node case ElementNode(
      tag: 'pre',
      :final children,
      :final attributes,
    )) {
      // Extract attributes
      final language =
          (attributes['language'] ??
                  attributes['lang'] ??
                  _extractLanguageFromClass(attributes['class']))
              as String;

      final title = attributes['title'];
      final showLineNumbers =
          attributes['showLineNumbers'] == 'true' ||
          attributes['show-line-numbers'] == 'true';
      final lineNumberStart =
          int.tryParse(
            attributes['lineNumberStart'] ??
                attributes['line-number-start'] ??
                '1',
          ) ??
          1;
      final highlightLines =
          attributes['highlightLines'] ?? attributes['highlight-lines'];
      final tag = attributes['tag'];
      final noHighlight =
          attributes['noHighlight'] == 'true' ||
          attributes['no-highlight'] == 'true';

      // Handle nested code element in pre
      var source = node.innerText;
      if (node.tag == 'pre' && children != null && children.isNotEmpty) {
        final firstChild = children.first;
        if (firstChild is ElementNode && firstChild.tag == 'code') {
          source = firstChild.innerText;
        }
      }

      // Initialize highlighter if needed
      if (!_initialized) {
        Highlighter.initialize(['dart']);
        for (final entry in grammars.entries) {
          Highlighter.addLanguage(entry.key, entry.value);
        }
        _initialized = true;
      }

      return AsyncBuilder(
        builder: (context) async* {
          Highlighter? highlighter;

          if (!noHighlight && _isSupportedLanguage(language)) {
            highlighter = Highlighter(
              language: language,
              theme:
                  theme ??
                  (_defaultTheme ??= await HighlighterTheme.loadDarkTheme()),
            );
          }

          yield DashCodeBlock(
            source: source,
            language: language,
            title: title,
            showLineNumbers: showLineNumbers,
            lineNumberStart: lineNumberStart,
            highlightLines: highlightLines,
            tag: tag,
            noHighlight: noHighlight,
            highlighter: highlighter,
          );
        },
      );
    }

    return null;
  }

  String? _extractLanguageFromClass(String? className) {
    if (className == null) return null;

    final langMatch = RegExp(r'language-(\w+)').firstMatch(className);
    return langMatch?.group(1);
  }

  bool _isSupportedLanguage(String language) {
    // List of commonly supported languages
    const supportedLanguages = {
      'dart',
      'yaml',
      'json',
      'swift',
      'css',
      'html',
      'xml',
      'js',
      'javascript',
      'objc',
      'bash',
      'sh',
      'kotlin',
      'java',
      'md',
      'markdown',
      'diff',
      'ps',
      'powershell',
      'console',
      'cmd',
      'plaintext',
      'text',
    };

    return supportedLanguages.contains(language.toLowerCase()) ||
        grammars.containsKey(language);
  }
}

/// A custom code block component with enhanced functionality including:
/// - Syntax highlighting
/// - Line numbers
/// - Line highlighting
/// - Inline text marking
/// - Title/header support
/// - Code block tags (good/bad/passes-sa/fails-sa)
class DashCodeBlock extends StatelessComponent {
  const DashCodeBlock({
    required this.source,
    required this.language,
    this.title,
    this.showLineNumbers = false,
    this.lineNumberStart = 1,
    this.highlightLines,
    this.tag,
    this.noHighlight = false,
    this.highlighter,
    super.key,
  });

  /// The source code to display
  final String source;

  /// The programming language for syntax highlighting
  final String language;

  /// Optional title/filename to display above the code
  final String? title;

  /// Whether to show line numbers
  final bool showLineNumbers;

  /// Starting line number (only used if showLineNumbers is true)
  final int lineNumberStart;

  /// Lines to highlight (comma-separated, supports ranges like "1-3,5,7-9")
  final String? highlightLines;

  /// Special tags like 'good', 'bad', 'passes-sa', 'fails-sa'
  final String? tag;

  /// Disable syntax highlighting
  final bool noHighlight;

  /// Optional syntax highlighter instance
  final Highlighter? highlighter;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    // Parse highlighted lines
    final highlightedLines = _parseHighlightedLines(highlightLines);

    // Process source to handle inline marking
    final processedSource = _processInlineMarking(source);

    // Build the code block wrapper
    yield div(classes: 'code-block-wrapper language-$language', [
      // Optional header
      if (title != null) _buildHeader(),

      // Code block body
      div(classes: 'code-block-body', [
        // Language tag
        if (language.isNotEmpty && language != 'plaintext')
          span(classes: 'code-block-lang', [text(language)]),

        // Code block tag (good/bad/etc)
        if (tag != null) _buildTag(),

        // Pre element with code
        pre([
          code([
            if (noHighlight || highlighter == null)
              _buildPlainCode(processedSource, highlightedLines)
            else
              _buildHighlightedCode(processedSource, highlightedLines),
          ]),
        ]),
      ]),
    ]);
  }

  Component _buildHeader() {
    return div(classes: 'code-block-header', [
      span(classes: 'code-block-title', [text(title!)]),
    ]);
  }

  Component _buildTag() {
    final tagClass = switch (tag) {
      'good' => 'code-tag-good',
      'bad' => 'code-tag-bad',
      'passes-sa' => 'code-tag-passes-sa',
      'fails-sa' => 'code-tag-fails-sa',
      _ => 'code-tag',
    };

    final tagText = switch (tag) {
      'good' => 'Good',
      'bad' => 'Bad',
      'passes-sa' => 'Passes static analysis',
      'fails-sa' => 'Fails static analysis',
      _ => tag!,
    };

    return span(classes: 'code-block-tag $tagClass', [text(tagText)]);
  }

  Component _buildPlainCode(String code, Set<int> highlightedLines) {
    final lines = code.split('\n');
    final components = <Component>[];

    for (var i = 0; i < lines.length; i++) {
      final lineNum = lineNumberStart + i;
      final isHighlighted = highlightedLines.contains(lineNum);

      components.add(
        _buildLine(
          lines[i],
          lineNum,
          isHighlighted,
          isPlain: true,
        ),
      );

      if (i < lines.length - 1) {
        components.add(text('\n'));
      }
    }

    return Fragment(children: components);
  }

  Component _buildHighlightedCode(String code, Set<int> highlightedLines) {
    if (highlighter == null) {
      return _buildPlainCode(code, highlightedLines);
    }

    // Get highlighted spans
    final highlighted = highlighter!.highlight(code);

    // Split into lines while preserving highlighting
    final lines = _splitHighlightedIntoLines(highlighted);
    final components = <Component>[];

    for (var i = 0; i < lines.length; i++) {
      final lineNum = lineNumberStart + i;
      final isHighlighted = highlightedLines.contains(lineNum);

      components.add(
        _buildLine(
          '',
          lineNum,
          isHighlighted,
          spans: lines[i],
        ),
      );

      if (i < lines.length - 1) {
        components.add(text('\n'));
      }
    }

    return Fragment(children: components);
  }

  Component _buildLine(
    String content,
    int lineNumber,
    bool isHighlighted, {
    bool isPlain = false,
    List<Component>? spans,
  }) {
    final lineClasses = [
      'code-line',
      if (isHighlighted) 'highlighted-line',
    ].join(' ');

    final lineContent = <Component>[];

    // Add line number if enabled
    if (showLineNumbers) {
      lineContent.add(
        span(classes: 'line-number', [text('$lineNumber')]),
      );
    }

    // Add code content
    if (spans != null) {
      lineContent.addAll(spans);
    } else if (isPlain) {
      // Process for inline marking
      lineContent.addAll(_processLineForMarking(content));
    } else {
      lineContent.add(text(content));
    }

    return span(
      classes: lineClasses,
      attributes: {'data-line': '$lineNumber'},
      lineContent,
    );
  }

  List<Component> _processLineForMarking(String line) {
    final components = <Component>[];
    final regex = RegExp(r'\[!(.+?)!\]');
    var lastEnd = 0;

    for (final match in regex.allMatches(line)) {
      // Add text before the match
      if (match.start > lastEnd) {
        components.add(text(line.substring(lastEnd, match.start)));
      }

      // Add marked text
      components.add(
        span(classes: 'marked-text', [text(match.group(1)!)]),
      );

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < line.length) {
      components.add(text(line.substring(lastEnd)));
    }

    return components;
  }

  String _processInlineMarking(String source) {
    // For display, we want to show the marked text without the markers
    // But we'll handle the marking in _processLineForMarking
    return source;
  }

  Set<int> _parseHighlightedLines(String? lines) {
    if (lines == null || lines.isEmpty) return {};

    final highlighted = <int>{};
    final parts = lines.split(',');

    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.contains('-')) {
        // Range like "1-3"
        final range = trimmed.split('-');
        if (range.length == 2) {
          final start = int.tryParse(range[0].trim());
          final end = int.tryParse(range[1].trim());
          if (start != null && end != null) {
            for (var i = start; i <= end; i++) {
              highlighted.add(i);
            }
          }
        }
      } else {
        // Single line
        final line = int.tryParse(trimmed);
        if (line != null) {
          highlighted.add(line);
        }
      }
    }

    return highlighted;
  }

  List<List<Component>> _splitHighlightedIntoLines(TextSpan span) {
    final lines = <List<Component>>[];
    var currentLine = <Component>[];

    void processSpan(TextSpan span) {
      final text = span.text ?? '';

      if (text.contains('\n')) {
        final parts = text.split('\n');
        for (var i = 0; i < parts.length; i++) {
          if (i > 0) {
            lines.add(currentLine);
            currentLine = <Component>[];
          }
          if (parts[i].isNotEmpty) {
            //currentLine.add(_buildStyledSpan(parts[i], style));
          }
        }
      } else if (text.isNotEmpty) {
        //currentLine.add(_buildStyledSpan(text, style));
      }

      for (final child in span.children) {
        processSpan(child);
      }
    }

    processSpan(span);

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines;
  }
}
