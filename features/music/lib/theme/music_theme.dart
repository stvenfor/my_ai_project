import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// Prefer app [AppTheme.dark] / [VercelTokens]; these aliases keep call sites compiling.
final ThemeData musicListDarkTheme = AppTheme.dark;

final ThemeData musicDarkTheme = AppTheme.dark;

/// 首页迷你播放条高度（含 padding，不含 Tab 栏占位）。
const double musicMiniPlayerBarHeight = 72;

/// Material 3 [NavigationBar] 标准高度（与 [MainPage] 底部 Tab 对齐）。
const double musicMainTabBarHeight = 80.0;
