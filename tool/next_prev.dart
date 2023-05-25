import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

const frontMatterMarker = '---';

void main(List<String> args) {
  if (args.isEmpty) {
    throw ArgumentError(
      'You must specify which directory in /src '
      'should have prev-next information added!',
    );
  }

  final subdirectory = args[0];
  if (subdirectory.contains('src')) {
    throw ArgumentError(
      'You must specify a path from within /src such as language!',
    );
  }

  final baseDirectory = Directory('src/$subdirectory');

  if (!baseDirectory.existsSync()) {
    throw Exception(
      'The directory $baseDirectory does not exist.',
    );
  }

  final pageList = _getPageList(baseDirectory);
  _sortPageList(pageList);

  _doublyLinkPages(pageList);
  pageList.forEach(_updatePageLinks);

  print('Processed ${pageList.length} pages.');
}

List<Page> _getPageList(Directory baseDirectory) {
  final files = baseDirectory.listSync(recursive: true).whereType<File>().where(
        (FileSystemEntity entity) =>
            entity.path.endsWith('.md') && !entity.path.contains('index.md'),
      );

  final pages = files.map((e) => Page.parse(e)).whereNotNull();

  return pages.toList(growable: false);
}

void _sortPageList(List<Page> pageList) {
  pageList.sort((a, b) {
    final dirComp = a.dir.compareTo(b.dir);
    return dirComp != 0 ? dirComp : a.title.compareTo(b.title);
  });
}

void _doublyLinkPages(List<Page> orderedPageList) {
  Page? prev;
  for (final page in orderedPageList) {
    if (prev != null) {
      prev.next = page;
      page.prev = prev;
    }
    prev = page;
  }
}

void _updatePageLinks(Page page) {
  yamlRemoveKey(page.frontMatter, 'prevpage');
  yamlRemoveKey(page.frontMatter, 'nextpage');

  final prev = page.prev;
  if (prev != null) {
    yamlAppendKey(page.frontMatter, 'prevpage', prev);
  }

  final next = page.next;

  if (next != null) {
    yamlAppendKey(page.frontMatter, 'nextpage', next);
  }

  page.file.writeAsStringSync(page.content);
}

void _warn(String msg) => print('WARNING: $msg');

void yamlRemoveKey(List<String> frontMatter, String key) {
  final i = frontMatter.indexOf('$key:');
  if (i < 0) return;
  frontMatter.removeAt(i);
  while (i < frontMatter.length && frontMatter[i].startsWith(' ')) {
    frontMatter.removeAt(i);
  }
}

void yamlAppendKey(List<String> frontMatter, String key, Page page) {
  var i = frontMatter.length;
  var title = page.title;
  if (title.contains('"')) title = '"$title"';
  frontMatter.insert(i++, '$key:');
  frontMatter.insert(i++, '  title: $title');
  frontMatter.insert(i++, '  path: ${page.path}');
}

class Page {
  final File file;
  final String title;
  final String path;
  final String dir;

  Page? prev;
  Page? next;
  final List<String> frontMatter;
  final List<String> rest;

  // Page(this.file) : dir = p.dirname(file.path) {
  //   path = file.path.substring('src'.length); // Skip 'src' prefix
  //   path = path.substring(0, path.length - '.md'.length); // Drop '.md' suffix
  //   _readAndParsePage();
  // }

  Page._({
    required this.file,
    required this.path,
    required this.dir,
    required this.title,
    required this.frontMatter,
    required this.rest,
  });

  static Page? parse(File file) {
    final directory = p.dirname(file.path);
    var path = file.path.substring('src'.length); // Skip 'src' prefix
    path = path.substring(0, path.length - '.md'.length); // Drop '.md' suffix

    final content = file.readAsStringSync();
    final lines = content.split('\n');

    if (lines[0] != frontMatterMarker) {
      _warn(
        'Jekyll frontmatter expected but none found: ${file.path}',
      );

      return null;
    }

    final endOfFrontMatterIndex = lines.indexOf(frontMatterMarker, 1);
    if (endOfFrontMatterIndex < 0) {
      _warn(
        'Jekyll frontmatter has no ending "$frontMatterMarker" marker: ${file.path}',
      );

      return null;
    }

    final frontMatter = lines.getRange(1, endOfFrontMatterIndex).toList();
    final rest = lines
        .getRange(endOfFrontMatterIndex + 1, lines.length)
        .toList(growable: false);

    final yaml = loadYaml(frontMatter.join('\n'));

    final title = yaml['title'];

    if (title is! String) {
      _warn(
        'Jekyll frontmatter missing string title: ${file.path}',
      );

      return null;
    }

    return Page._(
      file: file,
      path: path,
      dir: directory,
      title: title,
      frontMatter: frontMatter,
      rest: rest,
    );
  }

  String get content {
    final output = [frontMatterMarker];
    output.addAll(frontMatter);
    output.add(frontMatterMarker);
    output.addAll(rest);
    return output.join('\n');
  }

  @override
  String toString() => path;
}
