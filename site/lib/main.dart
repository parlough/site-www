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
            pattern: 'Card',
            builder: (name, attributes, child) {
              return ContentCard(
                title: attributes['title']!,
                link: attributes['link'],
                child: child!,
              );
            },
          ),
          CustomComponent(
            pattern: 'YouTubeEmbed',
            builder: (name, attributes, child) {
              final rawVideoId = attributes['id'] as String;
              final videoTitle = attributes['title'] as String;
              final playlistId = attributes['playlist'];

              final String videoId;
              final int startTime;
              if (rawVideoId.contains('?')) {
                videoId = rawVideoId.split('?')[0];

                final idAndStartTime = videoId.split('start=');
                startTime = int.parse(idAndStartTime[1]);
              } else {
                startTime = 0;
                videoId = rawVideoId;
              }

              return raw('''
<lite-youtube videoid="$videoId" videotitle="$videoTitle" videoStartAt="$startTime" ${playlistId != null ? 'playlistid="$playlistId"' : ''}>
  <p><a class="lite-youtube-fallback" href="https://www.youtube.com/watch/$videoId" target="_blank" rel="noopener">Watch on YouTube in a new tab: "$videoId"</a></p>
</lite-youtube>`
''');
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
