import 'package:flutter/material.dart';

/// Centralized palette for Call Recorder Automatic.
///
/// Hierarchy:
/// - Maroon / red → brand, splash, app bar gradient
/// - Green → phone / microphone accent
/// - Purple → navigation, chips, interactive controls
/// - Neutrals → surfaces, text, borders
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────
  static const brandMaroon = Color(0xFF800000);
  static const brandMaroonDark = Color(0xFF5A0000);
  static const brandMaroonLight = Color(0xFF9E2424);
  static const brandRed = Color(0xFFC62828);
  static const brandGreen = Color(0xFF43A047);

  /// Aliases kept for existing references.
  static const splashBackground = brandMaroon;
  static const logoRed = brandRed;
  static const logoGreen = brandGreen;
  static const emptyIconRed = brandMaroonDark;

  // ── Primary accent (navigation, buttons, toggles) ────────────────────
  static const primary = Color(0xFF7B5EA7);
  static const primaryPurple = primary;
  static const primaryLight = Color(0xFFAB91CF);
  static const primaryDark = Color(0xFF5E4785);
  static const primarySoft = Color(0x1A7B5EA7);

  // ── App bar & status bar (maroon-rose family) ────────────────────────
  static const gradientStart = Color(0xFF9B3030);
  static const gradientEnd = Color(0xFFBF5A5A);
  static const statusBarPurple = Color(0xFF8B4545);
  static const appBarForeground = Color(0xFFFFFFFF);

  static const appBarGradient = [gradientStart, gradientEnd];

  // ── Surfaces & borders ─────────────────────────────────────────────────
  static const background = Color(0xFFF7F7F8);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFFFFFFF);
  static const border = Color(0xFFE4E4E7);
  static const borderLight = Color(0xFFF0F0F2);
  static const divider = Color(0xFFEBEBED);

  // ── Text ───────────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF1C1C1E);
  static const textSecondary = Color(0xFF6B6B6E);
  static const textTertiary = Color(0xFF9E9EA2);
  static const iconMuted = Color(0xFFB4B4B8);

  // ── Semantic ───────────────────────────────────────────────────────────
  static const error = Color(0xFFD32F2F);
  static const errorDark = Color(0xFFB71C1C);
  static const errorLight = Color(0xFFFDECEC);
  static const errorBorder = Color(0xFFF5C6C6);
  static const onError = Color(0xFFFFFFFF);

  // ── Component tints ────────────────────────────────────────────────────
  static const chipBackground = primarySoft;
  static const infoBannerBackground = Color(0x14800000);
  static const infoBannerBorder = Color(0x33800000);
  static const consentBackground = Color(0xFFF5F2FA);
  static const consentBorder = Color(0x337B5EA7);
  static const cardShadow = Color(0x1A000000);
}
