import 'package:dart_dev_site/components/breadcrumbs.dart';
import 'package:dart_dev_site/components/prev_next.dart';
import 'package:dart_dev_site/components/trailing_content.dart';
import 'package:dart_dev_site/layouts/dash_layout.dart';
import 'package:dart_dev_site/util.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';

class DocLayout extends DashLayout {
  const DocLayout();

  @override
  String get name => 'docs';

  @override
  Component buildBody(Page page, Component child) {
    final pageData = page.data['page']!;
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
            if (pageData['show_breadcrumbs'] == true) Breadcrumbs(),
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
          TrailingContent(),
        ]),
      ]),
    );
  }
}
