import 'package:flutter/material.dart';

class SinglePageRoute extends PageRouteBuilder {
  final Widget? page;
  final RouteSettings? routeSettings;
  SinglePageRoute({this.page,this.routeSettings})
      : super(
      settings: routeSettings,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) =>
      page!);
}

// navigator channel method holds the bottom bar with respect to value of boolean parameter.

mixin NavigationChannel{
    Future<T?> navigatorChannel<T>(
  BuildContext context, {
  required Widget screen,
  bool? haveBottomBar,
  })
  {
  haveBottomBar ??= true;
  return Navigator.of(context, rootNavigator: !haveBottomBar).push<T>(
  getPageRoute(enterPage: screen));
  }

  dynamic getPageRoute(
  {RouteSettings? settings, Widget? enterPage, Widget? exitPage}) {
  return SinglePageRoute(
  page: enterPage,
  routeSettings: settings);
  }
}