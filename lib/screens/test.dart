import 'package:flutter/material.dart';
import 'package:level/components/box.dart';
import 'package:level/components/button.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: MyBox(
          color: Colors.deepPurple[300],
          child: MyButton(color: Colors.deepPurple[200], onTap: () {}),
        ),
      ),
    );
  }
}
