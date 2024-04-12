import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class Routerconfig {
  Routerconfig._();

  static String initR = '/home';
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: initR,
    navigatorKey: _rootNavigatorKey,
    routes: <RouteBase>[],
  );
}
