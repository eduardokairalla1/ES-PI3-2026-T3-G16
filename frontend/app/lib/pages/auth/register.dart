// --- Register page ---

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/core/exceptions/auth.dart';
import 'package:mesclainvest/core/exceptions/infrastructure.dart';
import 'package:mesclainvest/core/services/auth.dart';


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


  /// I submit the register form.
  /// 
  /// returns: void
  Future<void> _submit() async {

    // set loading state and clear previous error
    setState(() { _isLoading = true; _error = null; });

    // try to register the user
    try {
      await _authService.register(
        _emailController.text,
        _passwordController.text
      );

      // registration successful: navigate to the login page
      if (mounted) context.go('/login');
    }

    // authentication error: display the error message
    on AuthException catch (e) {
      setState(() => _error = e.message);
    }

    // infrastructure error: display the error message
    on InfrastructureException {
      setState(
        () => _error = ('Ocorreu um erro inesperado. '
                        'Tente novamente em alguns minutos.')
      );
    }

    // any other error: display a generic error message
    catch (_) {
      setState(
        () => _error = ('Ocorreu um erro inesperado. '
                        'Tente novamente em alguns minutos.')
      );
    }

    // reset loading state
    finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

            // error message
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],

            // register button
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Cadastrar'),
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
