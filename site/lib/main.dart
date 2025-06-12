import 'package:dart_dev_site/layouts/homepage_layout.dart';
import 'package:dart_dev_site/markdown/alert_syntax.dart';
import 'package:dart_dev_site/markdown/definition_list_syntax.dart';
import 'package:jaspr/server.dart';

import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/theme.dart';
import 'package:markdown/markdown.dart' as md;

// This file is generated automatically by Jaspr, do not remove or edit.
import 'jaspr_options.dart';

void main() {
  // Initializes the server environment with the generated default options.
  Jaspr.initializeApp(options: defaultJasprOptions);

  final markdownDocumentBuilder = md.Document(
    blockSyntaxes: [
      ComponentBlockSyntax(),
      AlertBlockSyntax(),
      DefinitionListSyntax(),
      md.FootnoteDefSyntax(),
    ],
    extensionSet: md.ExtensionSet.gitHubWeb,
  );

  runApp(
    ContentApp.custom(
      eagerlyLoadAllPages: true,
      loaders: [FilesystemLoader('content')],
      configResolver: PageConfig.all(
        dataLoaders: [FilesystemDataLoader('data')],
        templateEngine: LiquidTemplateEngine(),
        parsers: [
          MarkdownParser(documentBuilder: (_) => markdownDocumentBuilder),
          HtmlParser(),
        ],
        extensions: [HeadingAnchorsExtension(), TableOfContentsExtension()],
        components: [],
        layouts: [HomepageLayout(), DocsLayout()],
        // Don't apply default theming and styles.
        theme: ContentTheme.none(),
      ),
    ),
  );
}
