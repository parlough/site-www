import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/theme.dart';
import 'package:markdown/markdown.dart' as md;

import 'components/card.dart';

// This file is generated automatically by Jaspr, do not remove or edit.
import 'jaspr_options.dart';
import 'layouts/doc_layout.dart';
import 'layouts/homepage_layout.dart';
import 'markdown/alert_syntax.dart';
import 'markdown/definition_list_syntax.dart';
import 'pages/robots_txt.dart';

void main() {
  // Initializes the server environment with the generated default options.
  Jaspr.initializeApp(options: defaultJasprOptions);

  final markdownDocumentBuilder = md.Document(
    blockSyntaxes: const [
      ComponentBlockSyntax(),
      AlertBlockSyntax(),
      DefinitionListSyntax(),
      md.FootnoteDefSyntax(),
      md.HtmlBlockSyntax(),
    ],
    extensionSet: md.ExtensionSet.gitHubWeb,
  );

  // FilterRegistry.register('sum', (value, args, namedArgs) {
  //   if (value is! List) {
  //     return value;
  //   }
  //   return (value as List<int>).reduce((int a, int b) => a + b);
  // });

  runApp(
    ContentApp.custom(
      eagerlyLoadAllPages: true,
      loaders: [
        FilesystemLoader('content'),
        MemoryLoader(
          pages: [
            //   MemoryPage.builder(
            //     path: 'map.html',
            //     builder: (page) {
            //       return p([text('Dynamic Page: ${page.data['title']}')]);
            //     },
            //     applyLayout: true,
            //     data: {
            //       'title': 'Document index',
            //       'description':
            //           'Human-readable sitemap of all pages on dart.dev.',
            //       'layout': 'docs',
            //       'toc': false,
            //     },
            //   ),
          ],
        ),
      ],
      configResolver: PageConfig.all(
        dataLoaders: [FilesystemDataLoader('data')],
        templateEngine: const LiquidTemplateEngine(
          includesPath: 'content/_includes/',
        ),
        parsers: [
          MarkdownParser(documentBuilder: (_) => markdownDocumentBuilder),
          const HtmlParser(),
        ],
        rawOutputPattern: RegExp(r'.*\.txt$'),
        extensions: [
          HeadingAnchorsExtension(),
          const TableOfContentsExtension(),
        ],
        components: [
          CustomComponent(
            pattern: 'card',
            builder: (name, attributes, child) {
              return ContentCard(
                title: attributes['title']!,
                link: attributes['link'],
                child: child!,
              );
            },
          ),
        ],
        layouts: [const DocLayout(), const HomepageLayout()],
        theme: const ContentTheme.none(),
        secondaryOutputs: [RobotsTxtOutput()],
      ),
    ),
  );
}
