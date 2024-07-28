import 'package:flutter/material.dart';
import 'package:level/components/login_button.dart';
import 'package:level/router/navigation_bar.dart' as level_nav;
import '../components/login_textfield.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn(BuildContext context) {
    // Admin credentials
    const String adminEmail = "admin@xyma.in";
    const String adminPassword = "xyma@2024";

    // Get user input
    String email = usernameController.text;
    String password = passwordController.text;

    // Check if the entered credentials match the admin credentials
    if (email == adminEmail && password == adminPassword) {
      // Navigate to the new screen


      // Display a welcome message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome, Admin!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const level_nav.NavigationBar(),
        ),
      );

      // You can add any additional actions here after navigation
    } else {
      // Display an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon or Logo
            Image.asset(
              'lib/images/x.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 50),

            // Login Prompt
            const Text(
              'Log in to get started!!!',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 25),

            // Username TextField
            LoginTextfield(
              controller: usernameController,
              hintText: 'Username',
              obscureText: false,
            ),
            const SizedBox(height: 25),

            // Password TextField
            LoginTextfield(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 10),

            // Forgot Password Link
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Forget Password?',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Sign-in Button
            LoginButton(
              onTap: () => signUserIn(context),
            ),
            const SizedBox(height: 50),

            // Registration Prompt
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text(
            //       'Not a member?',
            //       style: TextStyle(color: Colors.grey[700]),
            //     ),
            //     const SizedBox(width: 4),
            //     GestureDetector(
            //       onTap: () {
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(builder: (context) => Register()),
            //         );
            //       },
            //       child: const Text(
            //         'Register now',
            //         style: TextStyle(
            //           color: Colors.blue,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
