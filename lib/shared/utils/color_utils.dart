import 'package:flutter/material.dart';

/// Parses a hex color string (`#RRGGBB`, `RRGGBB`, `#AARRGGBB`, `0xAARRGGBB`,
/// or `0xRRGGBB`), returning `null` if [hex] is null, empty, or malformed.
Color? tryParseHexColor(String? hex) {
  if (hex == null) return null;
  var normalized = hex.trim();
  if (normalized.isEmpty) return null;

  if (normalized.startsWith('#')) {
    normalized = normalized.substring(1);
  } else if (normalized.startsWith('0x') || normalized.startsWith('0X')) {
    normalized = normalized.substring(2);
  }

  if (normalized.length == 6) {
    normalized = 'FF$normalized';
  }
  if (normalized.length != 8) return null;

  final value = int.tryParse(normalized, radix: 16);
  if (value == null) return null;
  return Color(value);
}

/// Parses a hex color string, returning [fallback] when parsing fails.
Color parseHexColor(
  String? hex, {
  Color fallback = const Color(0xFF757575),
}) {
  return tryParseHexColor(hex) ?? fallback;
}
