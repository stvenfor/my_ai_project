import 'package:flutter/material.dart';

abstract final class SearchPageTheme {
  static const background = Colors.white;
  static const primaryGreen = Color(0xFF27BA6A);
  static const titleBlack = Color(0xFF1A1A1A);
  static const textGray = Color(0xFF666666);
  static const subtitleGray = Color(0xFF999999);
  static const tagBackground = Color(0xFFF5F5F5);
  static const tagText = Color(0xFF333333);
  static const searchFieldBackground = Color(0xFFF5F5F5);
  static const rankGold = Color(0xFFFFB800);
  static const rankSilver = Color(0xFFC0C0C0);
  static const rankBronze = Color(0xFFFF9A3C);
  static const divider = Color(0xFFEEEEEE);
}

abstract final class SearchAssets {
  static const package = 'module_home';
  static const basePath = 'assets/search';

  static String path(String assetName) => '$basePath/$assetName';
}
