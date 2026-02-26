// --- Register page ---

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


/// --- CODE ---

/// I represent the register page.
class RegisterPage extends StatefulWidget {

  // constructor
  const RegisterPage({super.key});


  /// I create the mutable state for this widget.
  /// 
  /// :returns: the state object for this widget.
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}


/// I represent the mutable state for the register page.
class _RegisterPageState extends State<RegisterPage> {

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


  /// I build the register page widget tree.
  /// 
  /// :param context: the build context
  /// 
  /// :returns: the register page widget tree
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // app bar
      appBar: AppBar(title: const Text('Registro')),

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

            // register button
            ElevatedButton(
              onPressed: () {},
              child: const Text('Register'),
            ),

            // login redirect
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Já tem uma conta? Iniciar sessão'),
            ),
          ],
        ),
      ),
    );
  }
}
