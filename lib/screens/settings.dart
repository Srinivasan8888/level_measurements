import 'package:flutter/material.dart';
import 'package:getwidget/components/toggle/gf_toggle.dart';
import 'package:getwidget/types/gf_toggle_type.dart';
import 'package:level/screens/test.dart';

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
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GFToggle(
                onChanged: (val) {},
                value: true,
                type: GFToggleType.ios,
              ),
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
