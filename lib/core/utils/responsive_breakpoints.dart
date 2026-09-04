import 'package:flutter/widgets.dart';

enum AppLayoutSize { phone, tablet }

abstract final class ResponsiveBreakpoints {
  static const double tablet = 720;

  static AppLayoutSize forWidth(double width) {
    return width >= tablet ? AppLayoutSize.tablet : AppLayoutSize.phone;
  }

  static bool isTablet(BoxConstraints constraints) {
    return forWidth(constraints.maxWidth) == AppLayoutSize.tablet;
  }
}
