import 'package:jaspr/jaspr.dart';

// Static navigation structure mirroring sidenav.yml
final List<NavEntry> defaultNav = [
  NavEntry.section('Language', [
    NavEntry.link('Introduction', '/language'),
    NavEntry.link('Variables', '/language/variables'),
    NavEntry.link('Operators', '/language/operators'),
    NavEntry.link('Comments', '/language/comments'),
    NavEntry.divider(),
    NavEntry.section('Types', [
      NavEntry.link('Built-in types', '/language/built-in-types'),
      NavEntry.link('Records', '/language/records'),
      NavEntry.link('Collections', '/language/collections'),
      NavEntry.link('Generics', '/language/generics'),
      NavEntry.link('Typedefs', '/language/typedefs'),
      NavEntry.link('Type system', '/language/type-system'),
    ]),
    NavEntry.section('Patterns', [
      NavEntry.link('Overview & usage', '/language/patterns'),
      NavEntry.link('Pattern types', '/language/pattern-types'),
      NavEntry.link(
        'Applied tutorial',
        'https://codelabs.developers.google.com/codelabs/dart-patterns-records',
      ),
    ]),
    NavEntry.section('Control flow', [
      NavEntry.link('Loops', '/language/loops'),
      NavEntry.link('Branches', '/language/branches'),
      NavEntry.link('Error handling', '/language/error-handling'),
    ]),
    NavEntry.link('Functions', '/language/functions'),
    NavEntry.link('Metadata', '/language/metadata'),
    NavEntry.link('Libraries & imports', '/language/libraries'),
    NavEntry.section('Classes & objects', [
      NavEntry.link('Classes', '/language/classes'),
      NavEntry.link('Constructors', '/language/constructors'),
      NavEntry.link('Methods', '/language/methods'),
      NavEntry.link('Extend a class', '/language/extend'),
      NavEntry.link('Mixins', '/language/mixins'),
      NavEntry.link('Enums', '/language/enums'),
      NavEntry.link('Extension methods', '/language/extension-methods'),
      NavEntry.link('Extension types', '/language/extension-types'),
      NavEntry.link('Callable objects', '/language/callable-objects'),
    ]),
    NavEntry.section('Class modifiers', [
      NavEntry.link('Overview & usage', '/language/class-modifiers'),
      NavEntry.link(
        'Class modifiers for API maintainers',
        '/language/class-modifiers-for-apis',
      ),
      NavEntry.link('Reference', '/language/modifier-reference'),
    ]),
    NavEntry.section('Concurrency', [
      NavEntry.link('Overview', '/language/concurrency'),
      NavEntry.link('Asynchronous programming', '/language/async'),
      NavEntry.link('Isolates', '/language/isolates'),
    ]),
    NavEntry.divider(),
    NavEntry.section('Null safety', [
      NavEntry.link('Sound null safety', '/null-safety'),
      NavEntry.link('Migrating to null safety', '/null-safety/migration-guide'),
      NavEntry.link(
        'Understanding null safety',
        '/null-safety/understanding-null-safety',
      ),
      NavEntry.link('Unsound null safety', '/null-safety/unsound-null-safety'),
      NavEntry.link('FAQ', '/null-safety/faq'),
    ]),
    NavEntry.link('Keywords', '/language/keywords'),
  ]),
  NavEntry.section('Core libraries', [
    NavEntry.link('Overview', '/libraries'),
    NavEntry.link('dart:core', '/libraries/dart-core'),
    NavEntry.link('dart:async', '/libraries/dart-async'),
    NavEntry.link('dart:math', '/libraries/dart-math'),
    NavEntry.link('dart:convert', '/libraries/dart-convert'),
    NavEntry.link('dart:io', '/libraries/dart-io'),
    NavEntry.link('dart:js_interop', '/interop/js-interop'),
    NavEntry.divider(),
    NavEntry.link('Iterable collections', '/libraries/collections/iterables'),
    NavEntry.section('Asynchronous programming', [
      NavEntry.link('Tutorial', '/libraries/async/async-await'),
      NavEntry.link(
        'Futures and error handling',
        '/libraries/async/futures-error-handling',
      ),
      NavEntry.link('Using streams', '/libraries/async/using-streams'),
      NavEntry.link('Creating streams', '/libraries/async/creating-streams'),
    ]),
  ]),
  NavEntry(
    title: 'Effective Dart',
    permalink: '/effective-dart',
    children: [
      NavEntry.link('Overview', '/effective-dart'),
      NavEntry.link('Style', '/effective-dart/style'),
      NavEntry.link('Documentation', '/effective-dart/documentation'),
      NavEntry.link('Usage', '/effective-dart/usage'),
      NavEntry.link('Design', '/effective-dart/design'),
    ],
  ),
  NavEntry.section('Packages', [
    NavEntry.link('How to use packages', '/tools/pub/packages'),
    NavEntry.link('Commonly used packages', '/resources/useful-packages'),
    NavEntry.link('Creating packages', '/tools/pub/create-packages'),
    NavEntry.link('Publishing packages', '/tools/pub/publishing'),
    NavEntry.link('Writing package pages', '/tools/pub/writing-package-pages'),
    NavEntry.link('Workspaces (monorepo support)', '/tools/pub/workspaces'),
    NavEntry.section('Package reference', [
      NavEntry.link('Dependencies', '/tools/pub/dependencies'),
      NavEntry.link('Glossary', '/tools/pub/glossary'),
      NavEntry.link('Package layout conventions', '/tools/pub/package-layout'),
      NavEntry.link(
        'Pub environment variables',
        '/tools/pub/environment-variables',
      ),
      NavEntry.link('Pubspec file', '/tools/pub/pubspec'),
      NavEntry.link('Troubleshooting pub', '/tools/pub/troubleshoot'),
      NavEntry.link('Verified publishers', '/tools/pub/verified-publishers'),
      NavEntry.link('Security advisories', '/tools/pub/security-advisories'),
      NavEntry.link('Versioning', '/tools/pub/versioning'),
      NavEntry.link(
        'Custom package repositories',
        '/tools/pub/custom-package-repositories',
      ),
    ]),
    NavEntry.link('What not to commit', '/tools/pub/private-files'),
  ]),
  NavEntry.section('Development', [
    NavEntry.link('JSON serialization', '/libraries/serialization/json'),
    NavEntry.link(
      'Number representation',
      '/resources/language/number-representation',
    ),
    NavEntry.link('Google APIs', '/resources/google-apis'),
    NavEntry.link('Multi-platform apps', '/multiplatform-apps'),
    NavEntry.section('Command-line & server apps', [
      NavEntry.link('Overview', '/server'),
      NavEntry.link('Get started', '/tutorials/server/get-started'),
      NavEntry.link('Write command-line apps', '/tutorials/server/cmdline'),
      NavEntry.link(
        'Fetch data from the internet',
        '/tutorials/server/fetch-data',
      ),
      NavEntry.link('Write HTTP servers', '/tutorials/server/httpserver'),
      NavEntry.link('Libraries & packages', '/server/libraries'),
      NavEntry.link('Google Cloud', '/server/google-cloud'),
    ]),
    NavEntry.section('Web apps', [
      NavEntry.link('Overview', '/web'),
      NavEntry.link('Get started', '/web/get-started'),
      NavEntry.link('Deployment', '/web/deployment'),
      NavEntry.link('Libraries & packages', '/web/libraries'),
      NavEntry.link('Wasm compilation', '/web/wasm'),
    ]),
    NavEntry.link(
      'Environment declarations',
      '/libraries/core/environment-declarations',
    ),
  ]),
  NavEntry.section('Interoperability', [
    NavEntry.link('C interop', '/interop/c-interop'),
    NavEntry.link(
      'Objective-C & Swift interop',
      '/interop/objective-c-interop',
    ),
    NavEntry.link('Java & Kotlin interop', '/interop/java-interop'),
    NavEntry.section('JavaScript interop', [
      NavEntry.link('Overview', '/interop/js-interop'),
      NavEntry.link('Usage', '/interop/js-interop/usage'),
      NavEntry.link('JS types', '/interop/js-interop/js-types'),
      NavEntry.link('Tutorials', '/interop/js-interop/tutorials'),
      NavEntry.link('Past JS interop', '/interop/js-interop/past-js-interop'),
      NavEntry.divider(),
      NavEntry.link('Web interop', '/interop/js-interop/package-web'),
    ]),
  ]),
  NavEntry.section('Tools & techniques', [
    NavEntry.link('Overview', '/tools'),
    NavEntry.section('Editors & debuggers', [
      NavEntry.link('IntelliJ & Android Studio', '/tools/jetbrains-plugin'),
      NavEntry.link('VS Code', '/tools/vs-code'),
      NavEntry.link('Dart DevTools', '/tools/dart-devtools'),
      NavEntry.section('DartPad', [
        NavEntry.link('Overview', '/tools/dartpad'),
        NavEntry.link('Troubleshooting DartPad', '/tools/dartpad/troubleshoot'),
      ]),
    ]),
    NavEntry.section('Command-line tools', [
      NavEntry.section('Dart SDK', [
        NavEntry.link('Overview', '/tools/sdk'),
        NavEntry.link('dart', '/tools/dart-tool'),
        NavEntry.link('dart analyze', '/tools/dart-analyze'),
        NavEntry.link('dart compile', '/tools/dart-compile'),
        NavEntry.link('dart create', '/tools/dart-create'),
        NavEntry.link('dart doc', '/tools/dart-doc'),
        NavEntry.link('dart fix', '/tools/dart-fix'),
        NavEntry.link('dart format', '/tools/dart-format'),
        NavEntry.link('dart info', '/tools/dart-info'),
        NavEntry.link('dart pub', '/tools/pub/cmd'),
        NavEntry.link('dart run', '/tools/dart-run'),
        NavEntry.link('dart test', '/tools/dart-test'),
        NavEntry.link('dartaotruntime', '/tools/dartaotruntime'),
        NavEntry.link('Experiment flags', '/tools/experiment-flags'),
      ], expanded: true),
      NavEntry.section('Other command-line tools', [
        NavEntry.link('build_runner', '/tools/build_runner'),
        NavEntry.link('webdev', '/tools/webdev'),
      ], expanded: true),
    ]),
    NavEntry.section('Static analysis', [
      NavEntry.link('Customizing static analysis', '/tools/analysis'),
      NavEntry.link(
        'Fixing type promotion failures',
        '/tools/non-promotion-reasons',
      ),
      NavEntry.link('Linter rules', '/tools/linter-rules'),
      NavEntry.link('Diagnostic messages', '/tools/diagnostics'),
    ]),
    NavEntry.section('Testing & optimization', [
      NavEntry.link('Testing', '/tools/testing'),
      NavEntry.link('Debugging web apps', '/web/debugging'),
    ]),
  ]),
  NavEntry.divider(),
  NavEntry.section('Resources', [
    NavEntry.link('Language cheatsheet', '/resources/dart-cheatsheet'),
    NavEntry.link('Breaking changes', '/resources/breaking-changes'),
    NavEntry.link('Language evolution', '/resources/language/evolution'),
    NavEntry.link('Language specification', '/resources/language/spec'),
    NavEntry.link('Dart 3 migration guide', '/resources/dart-3-migration'),
    NavEntry.section('Coming from ...', [
      NavEntry.link('JavaScript to Dart', '/resources/coming-from/js-to-dart'),
      NavEntry.link('Swift to Dart', '/resources/coming-from/swift-to-dart'),
    ]),
    NavEntry.divider(),
    NavEntry.link('FAQ', '/resources/faq'),
    NavEntry.link('Glossary', '/resources/glossary'),
    NavEntry.link('Books', '/resources/books'),
    NavEntry.link('Videos', '/resources/videos'),
    NavEntry.link('Tutorials', '/tutorials'),
  ]),
  NavEntry.section('Related sites', [
    NavEntry.link('API reference', 'https://api.dart.dev'),
    NavEntry.link('Blog', 'https://medium.com/dartlang'),
    NavEntry.link('DartPad (online editor)', 'https://dartpad.dev'),
    NavEntry.link('Flutter', 'https://flutter.dev'),
    NavEntry.link('Package site', 'https://pub.dev'),
  ], expanded: true),
];

// Data models for navigation structure
class NavEntry {
  final String? title;
  final String? permalink;
  final List<NavEntry>? children;
  final bool expanded;
  final bool header;
  final bool divider;

  const NavEntry({
    this.title,
    this.permalink,
    this.children,
    this.expanded = false,
    this.header = false,
    this.divider = false,
  });

  factory NavEntry.header(String title) => NavEntry(title: title, header: true);
  factory NavEntry.divider() => const NavEntry(divider: true);
  factory NavEntry.link(String title, String permalink) =>
      NavEntry(title: title, permalink: permalink);
  factory NavEntry.section(
    String title,
    List<NavEntry> children, {
    bool expanded = false,
  }) => NavEntry(title: title, children: children, expanded: expanded);
}

class SideNav extends StatelessComponent {
  const SideNav({
    super.key,
    required this.nav,
    required this.pageUrlPath,
    this.baseId = 'docs',
  });

  final List<NavEntry> nav;
  final String pageUrlPath;
  final String baseId;

  @override
  Iterable<Component> build(BuildContext context) {
    // Calculate active entries based on current page URL.
    final activeEntries = _calculateActiveEntries(pageUrlPath, nav);

    return [
      div(id: 'sidenav', [
        form(action: '/search/', classes: 'site-header-search form-inline', [
          input(
            classes: 'site-header-searchfield search-field',
            type: InputType.search,
            name: 'q',
            id: 'search-side',
            attributes: {
              'autocomplete': 'off',
              'placeholder': 'Search',
              'aria-label': 'Search',
            },
            [],
          ),
        ]),
        ul(classes: 'navbar-nav', [
          li(
            attributes: {'aria-hidden': 'true'},
            [div(classes: 'sidenav-divider', [])],
          ),
          li(classes: 'nav-item', [
            a(href: '/overview', classes: 'nav-link', [text('Overview')]),
          ]),
          li(classes: 'nav-item', [
            a(href: '/community', classes: 'nav-link', [text('Community')]),
          ]),
          li(classes: 'nav-item', [
            a(href: 'https://dartpad.dev', classes: 'nav-link', [
              text('Try Dart'),
            ]),
          ]),
          li(classes: 'nav-item', [
            a(href: '/get-dart', classes: 'nav-link', [text('Get Dart')]),
          ]),
          li(classes: 'nav-item', [
            a(href: '/docs', classes: 'nav-link', [text('Docs')]),
          ]),
          li(
            attributes: {'aria-hidden': 'true'},
            [div(classes: 'sidenav-divider', [])],
          ),
        ]),
        ul(classes: 'nav', _buildNavLevel(nav, activeEntries, baseId, 0)),
      ]),
    ];
  }

  List<Component> _buildNavLevel(
    List<NavEntry> entries,
    List<int> activeEntries,
    String parentId,
    int currentLevel,
  ) {
    final components = <Component>[];

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final isActive = _isEntryActive(activeEntries, currentLevel, i);
      final id = '$parentId-${i + 1}';

      if (entry.divider) {
        components.add(_buildDivider(currentLevel));
      } else if (entry.header) {
        components.add(_buildHeader(entry.title!));
      } else if (entry.children != null) {
        components.add(
          _buildCollapsibleSection(
            entry,
            id,
            isActive,
            activeEntries,
            currentLevel,
          ),
        );
      } else if (entry.permalink != null) {
        components.add(_buildLink(entry, isActive));
      }
    }

    return components;
  }

  Component _buildDivider(int level) {
    if (level == 0) {
      return li(
        attributes: {'aria-hidden': 'true'},
        [div(classes: 'sidenav-divider', [])],
      );
    } else {
      return div(classes: 'sidenav-divider', []);
    }
  }

  Component _buildHeader(String title) {
    return li(classes: 'nav-header', [text(title)]);
  }

  Component _buildCollapsibleSection(
    NavEntry entry,
    String id,
    bool isActive,
    List<int> activeEntries,
    int currentLevel,
  ) {
    final expanded = isActive || entry.expanded;
    final classes = ['nav-link', if (isActive) 'active', 'collapsible'];
    if (!expanded) classes.add('collapsed');

    return li(classes: 'nav-item', [
      button(
        classes: classes.join(' '),
        attributes: {
          'data-toggle': 'collapse',
          'data-target': '#$id',
          'role': 'button',
          'aria-expanded': expanded.toString(),
          'aria-controls': id,
        },
        [
          span([text(entry.title!)]),
          span(
            classes: 'material-symbols expander',
            attributes: {'aria-hidden': 'true'},
            [text('expand_more')],
          ),
        ],
      ),
      ul(
        classes: [
          'nav',
          'collapse',
          if (expanded) 'show',
        ].where((c) => c.isNotEmpty).join(' '),
        id: id,
        _buildNavLevel(entry.children!, activeEntries, id, currentLevel + 1),
      ),
    ]);
  }

  Component _buildLink(NavEntry entry, bool isActive) {
    final isExternal = entry.permalink!.contains('://');
    final classes = ['nav-link', if (isActive) 'active'];

    return li(classes: 'nav-item', [
      a(
        classes: classes.join(' '),
        href: entry.permalink!,
        target: isExternal ? Target.blank : null,
        attributes: isExternal ? {'rel': 'noopener'} : null,
        [
          div([
            span([text(entry.title!)]),
            if (isExternal)
              span(
                classes: 'material-symbols',
                attributes: {'aria-hidden': 'true'},
                [text('open_in_new')],
              ),
          ]),
        ],
      ),
    ]);
  }

  bool _isEntryActive(
    List<int> activeEntries,
    int currentLevel,
    int entryIndex,
  ) {
    if (activeEntries.length <= currentLevel) return false;
    return activeEntries[currentLevel] == entryIndex + 1;
  }

  // Calculate which navigation entries should be active based on current URL
  List<int> _calculateActiveEntries(String pageUrlPath, List<NavEntry> nav) {
    // Remove trailing slashes and index files for comparison
    final cleanPath = pageUrlPath.replaceAll(
      RegExp(r'/index$|/index\.html$|\.html$|/$'),
      '',
    );

    // This is a simplified version - in a real implementation, you'd want to
    // implement the same logic as the Liquid template's activeNavForPage filter
    final activeEntries = <int>[];

    // Find matching navigation entry and build active path
    _findActiveEntries(nav, cleanPath, activeEntries);

    return activeEntries;
  }

  bool _findActiveEntries(
    List<NavEntry> entries,
    String path,
    List<int> activeEntries,
  ) {
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];

      if (_entryMatchesPath(entry, path)) {
        activeEntries.add(i + 1);

        // If this entry has children, search them too
        if (entry.children != null) {
          _findActiveEntries(entry.children!, path, activeEntries);
        }
        return true;
      }

      // If this entry has children, search them recursively
      if (entry.children != null) {
        final childActiveEntries = <int>[];
        if (_findActiveEntries(entry.children!, path, childActiveEntries)) {
          activeEntries.add(i + 1);
          activeEntries.addAll(childActiveEntries);
          return true;
        }
      }
    }
    return false;
  }

  bool _entryMatchesPath(NavEntry entry, String path) {
    if (entry.permalink == null) return false;

    // Simple path matching - you might want to implement more sophisticated logic
    return path.startsWith(entry.permalink!) || entry.permalink == path;
  }
}
