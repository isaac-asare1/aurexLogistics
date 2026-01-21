import 'package:flutter/material.dart';

class Breakpoints {
  // Common web breakpoints (tweak anytime)
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobile && w < tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  /// A safe max width for centered web sections
  static double contentMaxWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= desktop) return 1200;
    if (w >= tablet) return 980;
    return w; // full width on small screens
  }

  /// Section padding that scales nicely
  static EdgeInsets sectionPadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= desktop) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 64);
    }
    if (w >= tablet) {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 56);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 40);
  }
}
