/// ***************************************************
/// Copyright 2019-2020 eBay Inc.
///
/// Use of this source code is governed by a BSD-style
/// license that can be found in the LICENSE file or at
/// https://opensource.org/licenses/BSD-3-Clause
/// ***************************************************
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

///By default, flutter test only uses a single "test" font called Ahem.
///
///This font is designed to show black spaces for every character and icon. This obviously makes goldens much less valuable.
///
///To make the goldens more useful, we have a utility to dynamically inject additional fonts into the flutter test engine so that we can get more human viewable output.
/// Path to your folder with fonts [from] in required
Future<void> loadAppFonts({@required String from}) async {
  if (_hasLoaded) {
    print('skipping fonts');
    return;
  }

  final fontsDir = Directory.fromUri(Uri(path: _getPath(from)));
  final Map<String, List<ByteData>> fontFamilies = {};
  await for (final entity in fontsDir.list()) {
    if (entity.path.endsWith('.ttf')) {
      final fontName =
          Uri.parse(entity.path).pathSegments.last.split('.ttf').first;
      final family = fontName.split('-').first;
      final Uint8List bytes = await File.fromUri(entity.uri).readAsBytes();
      final byteData = ByteData.view(bytes.buffer);
      fontFamilies[family] =
          [byteData].followedBy(fontFamilies[family] ?? []).toList();
    }
  }
  for (final family in fontFamilies.keys) {
    final loader = FontLoader(family);
    for (final font in fontFamilies[family]) {
      loader.addFont(Future.value(font));
    }
    await loader.load();
  }

  _hasLoaded = true;
}

bool _hasLoaded = false;

String _getPath(String directory) {
  if (Directory.current.path.endsWith('test')) {
    return '../$directory';
  } else {
    return directory;
  }
}
