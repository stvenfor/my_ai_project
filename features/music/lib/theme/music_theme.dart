import 'package:flutter/material.dart';

final ThemeData musicListDarkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  colorScheme: const ColorScheme.dark(
    primary: Colors.white,
    onPrimary: Colors.black,
    surface: Colors.black,
    onSurface: Colors.white,
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  sliderTheme: const SliderThemeData(
    thumbColor: Colors.white,
    activeTrackColor: Colors.tealAccent,
    inactiveTrackColor: Colors.white24,
  ),
);

final ThemeData musicDarkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Colors.white,
    onPrimary: Colors.black,
    surface: Colors.black,
    onSurface: Colors.white,
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  sliderTheme: const SliderThemeData(
    thumbColor: Colors.white,
    activeTrackColor: Colors.tealAccent,
    inactiveTrackColor: Colors.white24,
  ),
);

/// 首页迷你播放条高度（含 padding，不含 Tab 栏占位）。
const double musicMiniPlayerBarHeight = 72;

/// Material 3 [NavigationBar] 标准高度（与 [MainPage] 底部 Tab 对齐）。
const double musicMainTabBarHeight = 80.0;
