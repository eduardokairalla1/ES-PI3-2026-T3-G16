// --- Login page ---

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/core/exceptions/auth.dart';
import 'package:mesclainvest/core/exceptions/infrastructure.dart';
import 'package:mesclainvest/core/services/auth.dart';


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
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;


  /// I clean up the controllers when the widget is disposed.
  /// 
  /// :returns: void
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  /// I submit the login form.
  /// 
  /// returns: void
  Future<void> _submit() async {

    // set loading state and clear previous error
    setState(() { _isLoading = true; _error = null; });

    // try to sign in the user
    try {
      await _authService.signIn(
        _emailController.text,
        _passwordController.text
      );

      // login successful: navigate to the dashboard page
      if (mounted) context.go('/dashboard');
    }

    // authentication error: display the error message
    on AuthException catch (e) {
      setState(() => _error = e.message);
    }
    
    // infrastructure error: display the error message
    on InfrastructureException catch (e) {
      setState(() => _error = e.message);
    }

    // any other error: display a generic error message
    on Exception {
      setState(
        () => _error = 'An unexpected error occurred. Please try again.'
      );
    }

    // reset loading state
    finally {

      // widget is still mounted: reset the loading state
      if (mounted) setState(() => _isLoading = false);
    }
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

            // error message
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],

            // login button
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
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
