import 'package:flutter/material.dart';
import 'package:getwidget/components/toggle/gf_toggle.dart';
import 'package:getwidget/types/gf_toggle_type.dart';
import 'package:level/screens/test.dart';
import 'package:level/theme/theme.dart';
import 'package:level/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Settings'),
        ),
        endDrawer: Drawer(
          child: ListView(
            children: [
              ListTile(
                title: const Text("Light Mode"),
                trailing: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                  return GFToggle(
                      onChanged: (val) {
                        themeProvider.toggleTheme(); // Toggles theme on change
                      },
                      value: themeProvider.themeData == lightMode,
                      type: GFToggleType.ios);
                }),
              ),
              ListTile(
                title: const Text("Logout"),
                trailing: const Icon(Icons.logout),
                onTap: () {
                  print("logout pressed");
                },
              ),
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                child: const Text("Test Page"),
                onPressed: () {
                  // Use the aliased import when referring to your custom NavigationBar
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Test()));
                },
              ),
            ],
          ),
        ));
  }
}
