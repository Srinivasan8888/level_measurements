import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/toggle/gf_toggle.dart';
import 'package:getwidget/types/gf_toggle_type.dart';
import 'package:level/screens/test.dart';
import 'package:level/theme/theme.dart';
import 'package:level/theme/theme_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

Future<bool> _request_per(Permission permission) async {
  AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
  if (build.version.sdkInt >= 30) {
    var re = await Permission.manageExternalStorage.request();
    if (re.isGranted) {
      return true;
    } else {
      return false;
    }
  } else {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result.isGranted) {
        return true;
      } else {
        return false;
      }
    }
  }
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: const Text('Settings',
              style: TextStyle(
                fontFamily: 'Epilogue',
                fontWeight: FontWeight.w300,
                fontSize: 30,
              )),
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
              // ListTile(
              //   title: const Text("Logout"),
              //   trailing: const Icon(Icons.logout),
              //   onTap: () async {
              //     if(await _request_per(Permission.storage))=== true){
              //
              //     }
              //   },
              // ),
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
                  // Removed the 'const' keyword from the Test constructor
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyApp()));
                },
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (await _request_per(Permission.storage) == true) {
                      print('Permission in granted');
                    } else {
                      print('Permission is denied');
                    }
                  },
                  child: const Text("Storage Permission"))
            ],
          ),
        ));
  }
}
