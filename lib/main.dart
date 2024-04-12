import 'package:flutter/material.dart';
import 'package:level/router/navigation_bar.dart' as level_nav;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Level Measurement'),
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
