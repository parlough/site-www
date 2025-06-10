import 'package:dart_dev_site/layouts/homepage_layout.dart';
import 'package:jaspr/server.dart';

import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/theme.dart';

// This file is generated automatically by Jaspr, do not remove or edit.
import 'jaspr_options.dart';

void main() {
  // Initializes the server environment with the generated default options.
  Jaspr.initializeApp(options: defaultJasprOptions);

  runApp(
    ContentApp.custom(
      eagerlyLoadAllPages: true,
      loaders: [FilesystemLoader('content')],
      configResolver: PageConfig.all(
        dataLoaders: [FilesystemDataLoader('data')],
        templateEngine: LiquidTemplateEngine(),
        parsers: [MarkdownParser(), HtmlParser()],
        extensions: [HeadingAnchorsExtension(), TableOfContentsExtension()],
        components: [],
        layouts: [HomepageLayout(), DocsLayout()],
        // Don't apply default theming and styles.
        theme: ContentTheme.none(),
      ),
    ),
  );
}
