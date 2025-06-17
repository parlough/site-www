import 'package:liquify/liquify.dart';
import 'package:liquify/parser.dart';

class CommentTag extends AbstractTag with CustomTagParser {
  CommentTag(super.content, super.filters);

  @override
  void evaluate(Evaluator evaluator, Buffer buffer) {}

  @override
  Parser parser() {
    return (tagStart() &
            string('comment').trim() &
            tagEnd() &
            any()
                .starLazy(tagStart() & string('endcomment').trim() & tagEnd())
                .flatten() &
            tagStart() &
            string('endcomment').trim() &
            tagEnd())
        .map((values) {
          return Tag("comment", [], body: [TextNode(values[3])]);
        });
  }
}
