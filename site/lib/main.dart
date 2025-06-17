import 'package:dart_dev_site/components/card.dart';
import 'package:dart_dev_site/layouts/doc_layout.dart';
import 'package:dart_dev_site/layouts/homepage_layout.dart';
import 'package:dart_dev_site/liquid/comment_tag.dart';
import 'package:dart_dev_site/markdown/alert_syntax.dart';
import 'package:dart_dev_site/markdown/definition_list_syntax.dart';
import 'package:dart_dev_site/pages/robots_txt.dart';
import 'package:jaspr/server.dart';

import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/theme.dart';
import 'package:liquify/liquify.dart';
import 'package:markdown/markdown.dart' as md;

// This file is generated automatically by Jaspr, do not remove or edit.
import 'jaspr_options.dart';

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

  // TODO(parlough): Liquify should support comment tags itself.
  TagRegistry.register(
    'comment',
    (template, filters) => CommentTag(template, filters),
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
        templateEngine: LiquidTemplateEngine(
          includesPath: 'content/_includes/',
        ),
        parsers: [
          MarkdownParser(documentBuilder: (_) => markdownDocumentBuilder),
          HtmlParser(),
        ],
        rawOutputPattern: RegExp(r'.*\.txt$'),
        extensions: [HeadingAnchorsExtension(), TableOfContentsExtension()],
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
        layouts: [DocLayout(), HomepageLayout()],
        // Don't apply default theming and styles.
        // TODO(parlough): This seems to not work,
        //  still applies typography styles.
        theme: const ContentTheme.none(),
        secondaryOutputs: [RobotsTxtOutput()],
      ),
    ),
  );
}
