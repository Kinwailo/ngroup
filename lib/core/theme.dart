import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class NGroupTheme extends ThemeExtension<NGroupTheme> {
  const NGroupTheme({
    required this.isNew,
    required this.isRead,
    required this.title,
    required this.sender,
    required this.quote,
  });

  final Color? isNew;
  final Color? isRead;
  final Color? sender;
  final Color? title;
  final Color? quote;

  @override
  NGroupTheme copyWith({
    Color? isNew,
    Color? isRead,
    Color? sender,
    Color? title,
    Color? quote,
  }) {
    return NGroupTheme(
      isNew: isNew ?? this.isNew,
      isRead: isRead ?? this.isRead,
      sender: sender ?? this.sender,
      title: title ?? this.title,
      quote: quote ?? this.quote,
    );
  }

  @override
  NGroupTheme lerp(ThemeExtension<NGroupTheme>? other, double t) {
    if (other is! NGroupTheme) {
      return this;
    }
    return NGroupTheme(
      isNew: Color.lerp(isNew, other.isNew, t),
      isRead: Color.lerp(isRead, other.isRead, t),
      sender: Color.lerp(sender, other.sender, t),
      title: Color.lerp(title, other.title, t),
      quote: Color.lerp(quote, other.quote, t),
    );
  }
}

final lightNGroupThemeData = ligthThemeData.copyWith(
  extensions: <ThemeExtension<dynamic>>{
    NGroupTheme(
      isNew: Colors.deepOrangeAccent.shade200,
      isRead: Colors.greenAccent.shade700,
      title: Colors.white70,
      sender: Colors.lightBlueAccent.shade700,
      quote: Colors.blueGrey.shade100,
    ),
  },
);

final darkNGroupThemeData = darkThemeData.copyWith(
  extensions: <ThemeExtension<dynamic>>{
    NGroupTheme(
      isNew: Colors.deepOrangeAccent,
      isRead: Colors.greenAccent,
      title: Colors.white70,
      sender: Colors.lightBlueAccent,
      quote: Colors.blueGrey.shade700,
    ),
  },
);

final ligthThemeData = FlexThemeData.light(
  colors: const FlexSchemeColor(
    primary: Color(0xff18ffff),
    primaryContainer: Color(0xffd0e4ff),
    secondary: Color(0xff40c4ff),
    secondaryContainer: Color(0xffffdbcf),
    tertiary: Color(0xff006875),
    tertiaryContainer: Color(0xff95f0ff),
    appBarColor: Color(0xffffdbcf),
    error: Color(0xffb00020),
  ),
  surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
  blendLevel: 20,
  appBarOpacity: 0.90,
  subThemesData: const FlexSubThemesData(
    blendOnLevel: 20,
    blendOnColors: false,
    textButtonRadius: 4.0,
    elevatedButtonRadius: 4.0,
    outlinedButtonRadius: 4.0,
    inputDecoratorIsFilled: false,
    inputDecoratorBorderType: FlexInputBorderType.underline,
    inputDecoratorUnfocusedBorderIsColored: false,
    fabUseShape: false,
    fabSchemeColor: SchemeColor.primaryContainer,
    chipRadius: 20.0,
  ),
  keyColors: const FlexKeyColors(
    useTertiary: true,
  ),
  tones: FlexTones.soft(Brightness.light),
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
);

final darkThemeData = FlexThemeData.dark(
  colors: const FlexSchemeColor(
    primary: Color(0xff18ffff),
    primaryContainer: Color(0xff2a486c),
    secondary: Color(0xffa2b7b6),
    secondaryContainer: Color(0xff872100),
    tertiary: Color(0xffa9ccd4),
    tertiaryContainer: Color(0xff004e59),
    appBarColor: Color(0xff872100),
    error: Color(0xffcf6679),
  ),
  surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
  blendLevel: 15,
  appBarStyle: FlexAppBarStyle.primary,
  appBarOpacity: 0.90,
  darkIsTrueBlack: true,
  subThemesData: const FlexSubThemesData(
    blendOnLevel: 30,
    textButtonRadius: 4.0,
    elevatedButtonRadius: 4.0,
    outlinedButtonRadius: 4.0,
    inputDecoratorIsFilled: false,
    inputDecoratorBorderType: FlexInputBorderType.underline,
    inputDecoratorUnfocusedBorderIsColored: false,
    fabUseShape: false,
    fabSchemeColor: SchemeColor.primaryContainer,
    chipRadius: 20.0,
    appBarBackgroundSchemeColor: SchemeColor.primaryContainer,
  ),
  keyColors: const FlexKeyColors(
    useTertiary: true,
  ),
  tones: FlexTones.soft(Brightness.dark),
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
);
