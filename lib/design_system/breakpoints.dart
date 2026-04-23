/// App-wide layout breakpoints. Use with [MediaQuery] / [LayoutBuilder] width.
abstract final class AppBreakpoints {
  const AppBreakpoints._();

  static const double _tablet = 600;
  static const double _desktop = 1024;

  static bool isMobileWidth(double w) => w < _tablet;

  static bool isTabletWidth(double w) => w >= _tablet && w < _desktop;

  static bool isDesktopWidth(double w) => w >= _desktop;
}
