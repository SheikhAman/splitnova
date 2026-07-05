part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const HOME = _Paths.HOME;
  static const HISTORY = _Paths.HISTORY;
  static const SETTINGS = _Paths.SETTINGS;
  static const SUPPORT = _Paths.SUPPORT;
  static const TRIP_SUMMARY = _Paths.TRIP_SUMMARY;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const HOME = '/home';
  static const HISTORY = '/history';
  static const SETTINGS = '/settings';
  static const SUPPORT = '/support';
  static const TRIP_SUMMARY = '/trip-summary';
}
