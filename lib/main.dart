import 'package:flutter/material.dart';
import 'package:level/router/navigation_bar.dart' as level_nav;
import 'package:level/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => ThemeProvider(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Level Measurement'),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Let's get started!"),
          onPressed: () {
            // Use the aliased import when referring to your custom NavigationBar
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const level_nav.NavigationBar()));
          },
        ),
      ),
    );
  }
}
