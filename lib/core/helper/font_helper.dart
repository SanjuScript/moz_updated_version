import 'package:flutter/material.dart';

const _fontFamily = 'rounder';

/// Centralized typography styles
class   PerfectTypography {
  static TextStyle bold = const TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700, // Rounder SemiBold
  );

  static TextStyle medium = const TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500, // Rounder Medium
  );

  static TextStyle regular = const TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400, // Rounder Regular
  );

    static TextStyle normal = const TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.normal, // Rounder Normal
  );
}