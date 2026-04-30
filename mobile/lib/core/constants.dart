import 'package:flutter/material.dart';

class AppConstants {
  static const String defaultProvince = '08'; //code for bcn
  static const double defaultPadding = 24.0;
  static const int maxRefuges = 10;
  static const int timeoutDuration = 20; //seconds
  static const tabsPadding = EdgeInsets.fromLTRB(24, 12, 24, 16);
}

//color palette from https://es.pinterest.com/pin/492649954302676/
class AppColors {
  static const Color iris = Color(0xFF3B3686);
  static const Color reddish = Color(0xFF767AE6);
  static const Color apricot = Color(0xFFEDBA40);
  static const Color deepOrange = Color(0xFFE28C33);
  static const Color pureOrange = Color(0xFFE0652B);
  static const Color tintedBg = Color(0xFFF4F5FF);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1F1D45);

  //semantic alias
  static const Color primary = iris;

  static const Color secondary = reddish;

  static const Color accent = apricot;

  static const Color warning = deepOrange;

  static const Color error = pureOrange;

  static const Color background = tintedBg;

  static const Color surface = pureWhite;

  static const Color textPrimary = textDark;

  static const Color textSecondary = Color(0xFF5A587A);

  static const Color textHint = Color(0xFF9E9CBF);

  static const Color outline = Color(0xFFD0CFEA);

  static const Color divider = Color(0xFFE8E8F5);

  static const Color primaryTint = Color(0xFFECEBFA);

  static const Color secondaryTint = Color(0xFFE8E9FF);

  static const Color accentTint = Color(0xFFFDF3D6);

  static const Color warningTint = Color(0xFFFDF0E0);

  static const Color errorTint = Color(0xFFFFE8DF);
}
