import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level/screens/charts.dart';
import 'package:level/screens/home.dart';
import 'package:level/screens/reports.dart';
import 'package:level/screens/settings.dart';

class Approuter {
  GoRouter router = GoRouter(initialLocation: '/', routes: [
    GoRoute(
      name: 'home',
      path: '/',
      pageBuilder: (context, state) {
        return const MaterialPage(child: Home());
      },
    ),
    GoRoute(
      name: 'charts',
      path: '/charts',
      pageBuilder: (context, state) {
        return const MaterialPage(child: Charts());
      },
    ),
    GoRoute(
      name: 'reports',
      path: '/reports',
      pageBuilder: (context, state) {
        return const MaterialPage(child: Reports());
      },
    ),
    GoRoute(
      name: 'settings',
      path: '/settings',
      pageBuilder: (context, state) {
        return const MaterialPage(child: Settings());
      },
    ),
  ]);
}
