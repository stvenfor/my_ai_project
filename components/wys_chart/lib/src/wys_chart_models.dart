import 'package:flutter/material.dart';

@immutable
class WysBarDatum {
  const WysBarDatum({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final double value;
  final Color? color;
}

@immutable
class WysRadarDatum {
  const WysRadarDatum({
    required this.label,
    required this.value,
  });

  final String label;

  /// Expected on a 0–100 scale.
  final double value;
}
