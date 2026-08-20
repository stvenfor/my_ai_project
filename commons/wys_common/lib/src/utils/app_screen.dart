import 'package:flutter/widgets.dart';

/// Application-wide helpers for classifying the current logical window size.
abstract final class AppScreen {
  /// The logical-pixel shortest-side threshold used to classify large screens.
  static const double largeScreenBreakpoint = 600.0;

  /// Whether the window represented by [context] is a large screen.
  ///
  /// This reads the current [MediaQuery] size, so widgets that call this method
  /// rebuild with the correct result when a tablet enters split-screen mode or
  /// a foldable changes posture.
  static bool isLargeScreen(BuildContext context) {
    return isLargeSize(MediaQuery.sizeOf(context));
  }

  /// Whether [size] has a shortest side at or above the large-screen threshold.
  static bool isLargeSize(Size size) {
    return size.shortestSide >= largeScreenBreakpoint;
  }
}
