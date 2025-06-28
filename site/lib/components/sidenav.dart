import 'package:jaspr/jaspr.dart';

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

  /// Builds a navigation structure from YAML/JSON data.
  ///
  /// Expects data in the format used by src/data/sidenav.yml
  static List<NavEntry> navEntriesFromData(List<Object?> data) => data
      .map(
        (item) => switch (item) {
          'divider' => NavEntry.divider(),
          Map<String, Object?>() => _buildNavEntry(item),
          _ => throw ArgumentError('Invalid nav entry format: $item'),
        },
      )
      .toList(growable: false);

  static NavEntry _buildNavEntry(Map<String, Object?> item) {
    // Check for special entries that indicate a different entry type.
    if (item.containsKey('header')) {
      return NavEntry.header(item['header'] as String);
    }

    final title = item['title'] as String?;
    if (title == null) {
      throw ArgumentError(
        'Non-divider and non-header nav entries must '
        "have a 'title' specified.",
      );
    }

    final childrenData = item['children'] as List<Object?>?;

    if (childrenData != null) {
      // If specified, build children recursively.
      final children = navEntriesFromData(childrenData);
      if (children.isNotEmpty) {
        final expanded = item['expanded'] as bool? ?? false;
        return NavEntry.section(title, children, expanded: expanded);
      }
    } else {
      final permalink = item['permalink'] as String?;
      if (permalink != null) {
        return NavEntry.link(title, permalink);
      }
    }

    throw ArgumentError('Invalid nav entry format: $item');
  }

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

    for (var i = 0; i < entries.length; i++) {
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
    for (var i = 0; i < entries.length; i++) {
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

    return path.startsWith(entry.permalink!) || entry.permalink == path;
  }
}
