import 'package:jaspr/jaspr.dart';

class DashBanner extends StatelessComponent {
  const DashBanner({super.key});

  @override
  Iterable<Component> build(BuildContext context) {
    return [
      div(
        id: 'site-banner',
        attributes: {'role': 'alert'},
        [
          p([
            text('Dart and Flutter are back at Google I/O!'),
            a(
              href:
                  'https://io.google/2025/?utm_source=flutter&utm_medium=embedded_marketing&utm_campaign=hpp_livestream_banner&utm_content=',
              target: Target.blank,
              [text('Watch live keynotes & sessions')],
            ),
            br(),
          ]),
        ],
      ),
    ];
  }
}
