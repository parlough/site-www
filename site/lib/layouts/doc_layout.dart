import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';

class DocLayout extends PageLayoutBase {
  const DocLayout();

  @override
  String get name => 'docs';

  @override
  Component buildBody(Page page, Component child) {
    return child;
  }
}
