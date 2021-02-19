// Copyright 2019 the Dart project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:html';

class Snippet {
  final String name;
  final String sourceCode;

  Snippet(this.name, this.sourceCode);
}

class DartPadPicker {
  final String dartPadUrl;
  final Element iFrameHost;
  final SelectElement selectElement;
  final List<Snippet> snippets;
  final String /*?*/ frameId;
  IFrameElement _iFrameElement;
  int _selected = 0;

  DartPadPicker(this.iFrameHost, this.selectElement, this.snippets,
      {this.dartPadUrl = 'https://dartpad.dev', this.frameId}) {
    _initSelectElement();
    _initDartPad();
  }

  Snippet get _selectedSnippet => snippets[_selected];

  Map<String, dynamic> get _sourceCodeMessage => {
        'sourceCode': {
          'main.dart': _selectedSnippet.sourceCode,
        },
        'type': 'sourceCode'
      };

  void _initSelectElement() {
    for (var i = 0; i < snippets.length; i++) {
      var snippet = snippets[i];
      var option = OptionElement(value: '$i')..text = snippet.name;
      selectElement.children.add(option);
    }
    selectElement.onChange.listen((Event _) {
      _selected = selectElement.selectedIndex;
      _sendSourceCode();
    });
  }

  void _initDartPad() {
    _iFrameElement = IFrameElement()
      ..src = iFrameSrc(theme: 'dark', mode: 'dart');
    if (frameId != null) {
      _iFrameElement.id = frameId;
    }
    iFrameHost.children.add(_iFrameElement);
    window.addEventListener('message', (Event _e) {
      final e = _e as MessageEvent;
      // Don't handle events from other iframe elements
      if (e.data is Map &&
          e.data.containsKey('type') &&
          e.data['type'] is String &&
          e.data['type'] == 'ready') {
        _sendSourceCode();
      }
    });
  }

  void _sendSourceCode() {
    _iFrameElement.contentWindow.postMessage(_sourceCodeMessage, '*');
  }

  String iFrameSrc({String theme, String mode}) {
    return '${dartPadUrl}/embed-$mode.html?theme=$theme';
  }
}
