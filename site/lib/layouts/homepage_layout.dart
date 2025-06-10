import 'package:dart_dev_site/layouts/dash_layout.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';

class HomepageLayout extends DashLayout {
  const HomepageLayout();

  @override
  String get name => 'homepage';

  @override
  Component buildBody(Page page, Component child) {
    return Fragment(children: [
      Document.body(attributes: {'class': 'homepage'}),
      super.buildBody(page, child),
    ]);
  }
}
