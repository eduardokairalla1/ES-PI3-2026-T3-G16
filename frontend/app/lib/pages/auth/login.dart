// --- Login page ---

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


/// --- CODE ---

/// I represent the login page.
class LoginPage extends StatefulWidget {

  // constructor
  const LoginPage({super.key});


  /// I create the mutable state for this widget.
  /// 
  /// :returns: the state object for this widget.
  @override
  State<LoginPage> createState() => _LoginPageState();
}


/// I represent the mutable state for the login page.
class _LoginPageState extends State<LoginPage> {

  // define controllers for text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  /// I clean up the controllers when the widget is disposed.
  /// 
  /// :returns: void
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  /// I build the login page widget tree.
  /// 
  /// :param context: the build context
  /// 
  /// :returns: the login page widget tree
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // app bar
      appBar: AppBar(title: const Text('Login')),

      // page body
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // email field
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // password field
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 24),

            // login button
            ElevatedButton(
              onPressed: () {},
              child: const Text('Login'),
            ),

            // register redirect
            TextButton(
              onPressed: () => context.go('/register'),
              child: const Text('Não tem uma conta? Cadastre-se'),
            ),
          ],
        ),
      ),
    );
  }
}
