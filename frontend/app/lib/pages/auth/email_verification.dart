// --- Email verification page ---

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/core/exceptions/auth.dart';
import 'package:mesclainvest/core/exceptions/infrastructure.dart';
import 'package:mesclainvest/core/services/auth.dart';


/// --- CODE ---

/// I represent the email verification page shown after successful registration.
class EmailVerificationPage extends StatefulWidget {

  // the email to which the verification was sent
  final String email;

  // constructor
  const EmailVerificationPage({
    super.key,
    required this.email,
  });


  /// I create the mutable state for this widget.
  ///
  /// :returns: the state object for this widget.
  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}


/// I represent the mutable state for the email verification page.
class _EmailVerificationPageState extends State<EmailVerificationPage> {

  // service, controllers and UI state
  final _authService = AuthService();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _successMessage;


  /// I clean up the password controller when the widget is disposed.
  ///
  /// :returns: void
  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }


  /// I resend the verification email after re-authenticating with the given password.
  ///
  /// :returns: void
  Future<void> _resendEmail() async {

    // require password before attempting resend
    if (_passwordController.text.isEmpty) {
      setState(() => _error = 'Digite sua senha para reenviar o email.');
      return;
    }

    // set loading state and clear previous messages
    setState(() { _isLoading = true; _error = null; _successMessage = null; });

    // attempt to resend the verification email
    try {
      await _authService.resendVerificationEmail(
        widget.email,
        _passwordController.text,
      );

      // success: inform the user and clear the password field
      if (mounted) {
        _passwordController.clear();
        setState(() => _successMessage = 'Email de verificação reenviado!');
      }
    }

    // authentication error: display the error message
    on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }

    // infrastructure error: display a generic message
    on InfrastructureException {
      if (mounted) {
        setState(
          () => _error = 'Ocorreu um erro inesperado. Tente novamente.',
        );
      }
    }

    // any other error: display a generic message
    catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Ocorreu um erro inesperado. Tente novamente.',
        );
      }
    }

    // reset loading state
    finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  /// I build the email verification page widget tree.
  ///
  /// :param context: the build context
  ///
  /// :returns: the email verification page widget tree
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // app bar
      appBar: AppBar(title: const Text('Verifique seu email')),

      // page body
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // verification icon
            const Icon(Icons.mark_email_unread_outlined, size: 72),
            const SizedBox(height: 24),

            // main instruction text
            const Text(
              'Enviamos um link de verificação para:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),

            // display the target email address
            Text(
              widget.email,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // secondary instruction
            const Text(
              'Acesse sua caixa de entrada e clique no link para ativar '
              'sua conta antes de fazer login.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // password field for re-authentication on resend
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                helperText: 'Necessária para reenviar o email',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // error message
            if (_error != null) ...[
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],

            // success message
            if (_successMessage != null) ...[
              Text(
                _successMessage!,
                style: const TextStyle(color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],

            // resend email button
            ElevatedButton(
              onPressed: _isLoading ? null : _resendEmail,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Reenviar email'),
            ),
            const SizedBox(height: 12),

            // navigate to login button
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Ir para o login'),
            ),
          ],
        ),
      ),
    );
  }
}
