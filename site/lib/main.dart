import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/theme.dart';
import 'package:liquify/liquify.dart' show FilterRegistry;

import 'components/card.dart';

import 'jaspr_options.dart'; // Generated. Do not remove or edit.
import 'layouts/doc_layout.dart';
import 'layouts/homepage_layout.dart';
import 'markdown/markdown_parser.dart';
import 'pages/robots_txt.dart';

void main() {
  // Initializes the server environment with the generated default options.
  Jaspr.initializeApp(options: defaultJasprOptions);

  FilterRegistry.register('underscoreBreaker', (value, _, _) {
    if (value is! String) return value;

    return value.replaceAll('_', '_<wbr>');
  });

  runApp(
    ContentApp.custom(
      eagerlyLoadAllPages: true,
      loaders: [FilesystemLoader('content')],
      configResolver: PageConfig.all(
        dataLoaders: [FilesystemDataLoader('data')],
        templateEngine: const LiquidTemplateEngine(
          includesPath: 'content/_includes/',
        ),
        parsers: [const DashMarkdownParser(), const HtmlParser()],
        rawOutputPattern: RegExp(r'.*\.txt$'),
        extensions: [
          //AttributeProcessor(),
          //HeadingAnchorsExtension(),
          //const TableOfContentsExtension(),
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
