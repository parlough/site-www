import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';

class BreadcrumbItem {
  const BreadcrumbItem({required this.title, required this.url});

  final String title;
  final String url;
}

/// Breadcrumbs navigation component that follows ARIA guidelines and includes RDFa markup
/// References:
/// - https://developers.google.com/search/docs/data-types/breadcrumb
/// - https://schema.org/BreadcrumbList
/// - https://www.w3.org/TR/wai-aria-practices/examples/breadcrumb/index.html
class Breadcrumbs extends StatelessComponent {
  const Breadcrumbs({super.key, this.breadcrumbs});

  final List<BreadcrumbItem>? breadcrumbs;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final page = context.page;
    final pageUrl = page.url;

    final cleanUrl = pageUrl.replaceAll(
      RegExp(r'/index$|/index\.html$|/$'),
      '',
    );

    // Only show breadcrumbs if we have a non-empty URL.
    if (cleanUrl.isEmpty) return;

    // Get breadcrumbs from page data or use provided breadcrumbs.
    final crumbs = breadcrumbs ?? _getBreadcrumbsFromPage(page);

    if (crumbs.isEmpty) return;

    yield nav(
      classes: 'breadcrumbs',
      attributes: {'aria-label': 'breadcrumb'},
      [
        ol(
          classes: 'breadcrumb-list',
          attributes: {
            'vocab': 'http://schema.org/',
            'typeof': 'BreadcrumbList',
          },
          [
            for (int i = 0; i < crumbs.length; i++)
              _BreadcrumbItemComponent(
                crumb: crumbs[i],
                index: i,
                isLast: i == crumbs.length - 1,
              ),
          ],
        ),
      ],
    );
  }

  /// Extract breadcrumbs from page data
  /// This would typically call a custom filter or function to generate breadcrumbs
  /// based on the page's position in the site hierarchy
  List<BreadcrumbItem> _getBreadcrumbsFromPage(Page page) {
    // In the original template, this uses: {% assign breadcrumbs = page | breadcrumbsForPage -%}
    // This would need to be implemented based on your site's structure
    // For now, we'll return an empty list and expect breadcrumbs to be passed in

    // You could implement logic here to generate breadcrumbs based on:
    // - page.url path segments
    // - page.data navigation structure
    // - site configuration

    final breadcrumbsData = page.data['breadcrumbs'] as List<Object?>?;
    if (breadcrumbsData == null) return [];

    return breadcrumbsData
        .cast<Map<String, Object?>>()
        .map(
          (crumb) => BreadcrumbItem(
            title: crumb['title'] as String,
            url: crumb['url'] as String,
          ),
        )
        .toList();
  }
}

/// Private stateless component for rendering individual breadcrumb items
class _BreadcrumbItemComponent extends StatelessComponent {
  const _BreadcrumbItemComponent({
    required this.crumb,
    required this.index,
    required this.isLast,
  });

  final BreadcrumbItem crumb;
  final int index;
  final bool isLast;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final cleanUrl = crumb.url.replaceAll(
      RegExp(r'/index$|/index\.html$|/$'),
      '',
    );

    final classes = [
      'breadcrumb-item',
      if (isLast) 'active',
    ].where((c) => c.isNotEmpty).join(' ');

    yield li(
      classes: classes,
      attributes: {
        'property': 'itemListElement',
        'typeof': 'ListItem',
        if (isLast) 'aria-current': 'page',
      },
      [
        a(
          href: cleanUrl,
          attributes: {'property': 'item', 'typeof': 'WebPage'},
          [
            span(attributes: {'property': 'name'}, [text(crumb.title)]),
          ],
        ),
        meta(attributes: {'property': 'position', 'content': index.toString()}),
        if (!isLast)
          span(
            classes: 'material-symbols child-icon',
            attributes: {'aria-hidden': 'true'},
            [text('chevron_right')],
          ),
      ],
    );
  }
}
