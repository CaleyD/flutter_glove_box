# Golden Toolkit

[![Build Status](https://travis-ci.org/eBay/flutter_glove_box.svg?branch=master)](https://travis-ci.org/eBay/flutter_glove_box)[![codecov](https://codecov.io/gh/eBay/flutter_glove_box/branch/master/graph/badge.svg)](https://codecov.io/gh/eBay/flutter_glove_box)

This project contains APIs and utilities that build upon [Flutter's Golden test](https://github.com/flutter/flutter/wiki/Writing-a-golden-file-test-for-package:flutter) functionality to provide powerful UI regression tests.

It is highly recommended to look at sample tests here: [golden_builder_test.dart](test/golden_builder_test.dart)

## Table of Contents

- Key Features
  - [GoldenBuilder](#goldenbuilder)
  - [multiScreenGolden](#multiscreengolden)
- Getting Started
  - [Pumping Widgets](#Pumping-Widgets)
  - [Loading Fonts](#Loading-Fonts)
  - [testGoldens()](#testGoldens)

### GoldenBuilder

The GoldenBuilder class lets you quickly test various states of your widgets given different sizes, input values or accessibility options. A single test allows for all variations of your widget to be captured in a single Golden image that easily documents the behavior and prevents regression.

Consider the following WeatherCard widget:

![screenshot of widget under test](test/goldens/single_weather_card.png)

You might want to validate that the widget looks correct for different weather types:

```dart
testGoldens('Weather types should look correct', (tester) {
  final builder = GoldenBuilder.grid(columns:2)
          ..addScenario('Sunny', WeatherCard(Weather.sunny))
          ..addScenario('Cloudy', WeatherCard(Weather.cloudy))
          ..addScenario('Raining', WeatherCard(Weather.rain))
          ..addScenario('Cold', WeatherCard(Weather.cold));
  await tester.pumpWidgetBuilder(builder.build());
  await screenMatchesGolden(tester, 'weather_types_grid');
});
```

The output of this test will generate a golden: `weather_types_grid.png` that represents all four states in a single test asset.

![example GoldenBuilder output laid out in a grid](test/goldens/weather_types_grid.png)

A different use case may be validating how the widget looks with a variety of text sizes based on the user's device settings.

```dart
testGoldens('Weather Card - Accessibility', (tester) {
  final widget = WeatherCard(Weather.cloudy);
  final builder = GoldenBuilder.column()
          ..addScenario('Default font size', widget)
          ..addTextScaleScenario('Large font size', widget, textScaleFactor: 2.0)
          ..addTextScaleScenario('Largest font', widget, textScaleFactor: 3.2);
  await tester.pumpWidgetBuilder(builder.build());
  await screenMatchesGolden(tester, 'weather_accessibility');
});
```

The output of this test will be this golden file: `weather_accessibility.png`:

![example GoldenBuilder output showing different text scales](test/goldens/weather_accessibility.png)

See tests for usage examples: [golden_builder_test.dart](test/golden_builder_test.dart)

### multiScreenGolden

TBD

### Pumping Widgets

Flutter Test's `WidgetTester` already provides the ability to pump a widget for testing purposes.

However, in many cases it is common for the Widget under test to have a number of assumptions & dependencies about the widget tree it is included in. For example, it might require Material theming, or a particular Inherited Widget. Often this setup is common and shared across multiple widget tests.

For convenience, we've created an extension for [WidgetTester] with a function `pumpWidgetBuilder` to allow for easy configuration of the parent widget tree & device configuration to emulate.

`pumpWidgetBuilder` has optional parameters `wrapper`, `surfaceSize`, `textScaleSize`

This is entirely optional, but can help reduce boilerplate code duplication.

Example:

```dart
 await tester.pumpWidgetBuilder(yourWidget, surfaceSize: const Size(200, 200));
```

`wrapper` parameter is defaulted to `materialAppWrapper`, but you can use your own custom wrappers.

**Important**: `materialAppWrapper` allows your to inject specific platform, localizations, locales, theme and etc.

Example of injecting light Theme:

```dart
      await tester.pumpWidgetBuilder(
        yourWidget,
        wrapper: materialAppWrapper(
          theme: ThemeData.light(),
          platform: TargetPlatform.android,
        ),
      );
```

Note: you can create your own wrappers similar to `materialAppWrapper`

See more usage examples here: [golden_builder_test.dart](test/golden_builder_test.dart)

### Loading Fonts

By default, flutter test only uses a single "test" font called Ahem.
This font is designed to show black spaces for every character and icon. This obviously makes goldens much less valuable.

To make the goldens more useful, we have a utility to dynamically inject additional fonts into the flutter test engine so that we can get more human viewable output.
In order to inject your fonts, just call font loader function on top of your test file:

```dart
  await loadAppFonts(from: 'yourFontDirectoryPath');
```

Function will load all the fonts from that directory using FontLoader so they are properly rendered during the test.
Material icons like `Icons.battery` will be rendered in goldens ONLY if your pre-load MaterialIcons-Regular.ttf font that contains all the icons.

### testGoldens()

It is possible to use golden assertions in any testWidgets() test. As the UI for a widget evolves, it is common to need to regenerate goldens to capture your new reference images. The easiest way to do this is via the command-line:

```sh
flutter test --update-goldens
```

By default, this will execute all tests in the package. In a package with a large number of non-golden widget tests, we found this to be sub-optimal. We would much rather run ONLY the golden tests when regenerating. Initially, we arrived at a convention of ensuring that the test descriptions included the word 'Golden'

```sh
flutter test --update-goldens -name=Golden
```

However, there wasn't a way to enforce that developers named their tests appropriately, and this was error-prone.

Ultimately, we ended up making this `testGoldens()` function to enforce the convention. It has the same signature as `testWidgets` but it will automatically structure the tests so that the above flutter test command can work.

Additionally, the following test assertions will fail if not executed within testGoldens:

```dart
multiScreenGolden()
screenMatchesGolden()
```

## License Information

Copyright 2019-2020 eBay Inc.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

- Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above
  copyright notice, this list of conditions and the following disclaimer
  in the documentation and/or other materials provided with the
  distribution.
- Neither the name of eBay Inc. nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## 3rd Party Software Included or Modified in Project

This software contains some 3rd party software licensed under open source license terms:

1. Roboto Font File:
   Available at URL: [https://github.com/google/fonts/tree/master/apache/roboto](https://github.com/google/fonts/tree/master/apache/roboto)
   License: Available under Apache license at [https://github.com/google/fonts/blob/master/apache/roboto/LICENSE.txt](https://github.com/google/fonts/blob/master/apache/roboto/LICENSE.txt)

2. Material Icon File:
   URL: [https://github.com/google/material-design-icons](https://github.com/google/material-design-icons)
   License: Available under Apache license at [https://github.com/google/material-design-icons/blob/master/LICENSE](https://github.com/google/material-design-icons/blob/master/LICENSE)

3. Icons at:
   Author: Adnen Kadri
   URL: [https://www.iconfinder.com/iconsets/weather-281](https://www.iconfinder.com/iconsets/weather-281)
   License: Free for commercial use
