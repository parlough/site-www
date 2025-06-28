import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';

import '../components/breadcrumbs.dart';
import '../components/trailing_content.dart';
import '../util.dart';
import 'dash_layout.dart';

class DocLayout extends DashLayout {
  const DocLayout();

  @override
  String get name => 'docs';

  @override
  Component buildBody(Page page, Component child) {
    final pageData = page.data['page'] as Map<String, Object?>;
    final pageTitle = pageData['title'] as String;

    if (pageData['toc'] != false) {
      //NavigationTocSide(tocContents: page.data['tocContents'])
    }

    return super.buildBody(
      page,
      article([
        div(classes: 'content', [
          div(id: 'site-content-title', [
            h1([
              if (pageData['underscore_breaker_titles'] == true)
                ...underscoreBreaker(pageTitle)
              else
                text(pageTitle),
            ]),
            if (pageData['show_breadcrumbs'] != false) const PageBreadcrumbs(),
          ]),
          // if (pageData['toc'] != false)
          //   NavigationTocTop(tocContents: page.data['tocContents']),

          // Main content
          child,

          // Navigation between pages
          // PrevNext(
          //   prevPage: pageData['prevpage'],
          //   nextPage: pageData['nextpage'],
          // ),
          const TrailingContent(),
        ]),
      ]),
    );
  }
}
