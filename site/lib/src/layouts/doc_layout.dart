// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';

import '../components/common/page_header.dart';
import '../components/common/prev_next.dart';
import '../components/layout/toc.dart';
import '../components/layout/trailing_content.dart';
import '../extensions/header_extractor.dart';
import '../models/on_this_page_model.dart';
import 'dash_layout.dart';

/// The Jaspr Content layout to use for normal docs pages,
/// adding elements such as breadcrumbs, TOC, and prev/next cards.
class DocLayout extends DashLayout {
  const DocLayout();

  @override
  String get name => 'docs';

  bool get showTocDefault => true;

  @override
  Iterable<Component> buildHead(Page page) {
    final pageData = page.data.page;
    final prevUrl = _urlFromPageInfo(pageData['prevpage']);
    final nextUrl = _urlFromPageInfo(pageData['nextpage']);

    final urls = {
      if (prevUrl != null) prevUrl,
      if (nextUrl != null) nextUrl,
    };

    return [
      ...super.buildHead(page),
      if (urls.isNotEmpty) ...[
        // Use the Speculation Rules API to prerender prev/next pages,
        // with a prefetch fallback for browsers that don't support it.
        _speculationRulesScript(prerender: urls, prefetch: urls),
        for (final url in urls) link(rel: 'prefetch', href: url),
      ],
    ];
  }

  @override
  Component buildBody(Page page, Component child) {
    final pageData = page.data.page;
    final pageTitle = pageData['title'] as String;
    final pageDescription = (pageData['description'] as String?)?.trim();
    final tocData = _tocForPage(page);

    return super.buildBody(
      page,
      Component.fragment(
        [
          if (tocData == null)
            const Document.body(attributes: {'data-toc': 'false'})
          else
            NarrowTableOfContents(
              tocData,
              currentTitle: pageTitle,
            ),
          ?buildBanner(page),
          div(classes: 'after-leading-content', [
            if (tocData != null)
              aside(id: 'side-menu', [
                WideTableOfContents(tocData),
              ]),
            article([
              div(classes: 'content', [
                PageHeader(
                  title: pageTitle,
                  description: pageDescription,
                  showBreadcrumbs: pageData['showBreadcrumbs'] as bool? ?? true,
                  splitTitleByUnderscores:
                      pageData['underscore_breaker_titles'] as bool? ?? false,
                ),

                child,

                PrevNext(
                  previousPage: _pageInfoFromObject(pageData['prevpage']),
                  nextPage: _pageInfoFromObject(pageData['nextpage']),
                ),
                const TrailingContent(),
              ]),
            ]),
          ]),
        ],
      ),
    );
  }

  OnThisPageData? _tocForPage(Page page) {
    if (!showTocDefault) {
      return null;
    }

    final pageData = page.data.page;
    final showToc = pageData['showToc'] as bool? ?? true;

    // If 'showToc' was explicitly set to false, hide the toc.
    if (!showToc) return null;

    final onThisPageData = OnThisPageData.fromContentHeaders(
      page.data['contentHeaders'] as List<ContentHeader>? ?? const [],
      minLevel: pageData['minTocDepth'] as int? ?? 2,
      maxLevel: pageData['maxTocDepth'] as int? ?? 3,
    );

    // If there are less than 2 top-level entries, hide the toc.
    if (onThisPageData.topLevelEntries.length < 2) return null;

    return onThisPageData;
  }
}

({String url, String title})? _pageInfoFromObject(Object? data) {
  if (data case {
    'url': final String pageUrl,
    'title': final String pageTitle,
  }) {
    return (url: pageUrl, title: pageTitle);
  }

  return null;
}

/// Extracts and returns the `url` value from a page info map,
/// or `null` if [data] is not a map or has no `url` entry.
String? _urlFromPageInfo(Object? data) {
  if (data case {'url': final String url}) {
    return url;
  }
  return null;
}

/// Builds an inline `<script type="speculationrules">` element containing
/// a JSON object with [prerender] and [prefetch] URL lists.
///
/// See <https://developer.mozilla.org/en-US/docs/Web/API/Speculation_Rules_API>.
RawText _speculationRulesScript({
  Set<String> prerender = const {},
  Set<String> prefetch = const {},
}) {
  final rules = jsonEncode({
    if (prerender.isNotEmpty) 'prerender': [{'urls': [...prerender]}],
    if (prefetch.isNotEmpty) 'prefetch': [{'urls': [...prefetch]}],
  });

  return RawText('<script type="speculationrules">$rules</script>');
}
