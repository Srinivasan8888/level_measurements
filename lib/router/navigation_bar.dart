import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:level/screens/charts.dart';
import 'package:level/screens/home.dart';
import 'package:level/screens/reports.dart';
import 'package:level/screens/settings.dart';

class NavigationBar extends StatefulWidget {
  const NavigationBar({super.key});

  @override
  NavigationBarState createState() => NavigationBarState();
}

class NavigationBarState extends State<NavigationBar> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const Home(),
    const Charts(),
    const Reports(),
    const Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.tertiary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            // backgroundColor: Theme.of(context).colorScheme.primary,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Theme.of(context).colorScheme.secondary,
            tabBorderRadius: 100,
            gap: 8,
            haptic: true,
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(16),
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            tabs: const [
              GButton(
                icon: Icons.home,
                text: "Home",
              ),
              GButton(
                icon: Icons.bar_chart,
                text: "Charts",
              ),
              GButton(
                icon: Icons.report,
                text: "Reports",
              ),
              GButton(
                icon: Icons.settings,
                text: "Settings",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
