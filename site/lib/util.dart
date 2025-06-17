import 'package:jaspr/jaspr.dart';

const productionBuild = bool.fromEnvironment('PRODUCTION');

List<Component> underscoreBreaker(String sourceString) {
  final parts = sourceString.split('_');
  final result = <Component>[];

  for (int i = 0; i < parts.length; i++) {
    result.add(text(parts[i]));

    // Add a word break opportunity after each underscore,
    // except for the final one.
    if (i < parts.length - 1) {
      result.add(text('_'));
      result.add(DomComponent(tag: 'wbr'));
    }
  }

  return result;
}
