// --- Forgot password page ---

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesclainvest/core/exceptions/auth.dart';
import 'package:mesclainvest/core/exceptions/infrastructure.dart';
import 'package:mesclainvest/core/services/auth.dart';


// --- CONSTANTS ---
const _kFieldBg     = Color(0xFFF8F8F8);
const _kFieldBorder = Color(0xFFD4D4D4);
const _kLabel       = Color(0xFF424242);
const _kHint        = Color(0xFFA4A2A2);
const _kBody        = Color(0xFF454545);


// --- CODE ---

/// I represent the forgot password page.
class ForgotPasswordPage extends StatefulWidget {

  // constructor
  const ForgotPasswordPage({super.key});


  /// I create the mutable state for this widget.
  ///
  /// :returns: the state object for this widget.
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}


/// I represent the mutable state for the forgot password page.
class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {

  // controllers
  final _authService = AuthService();
  final _formKey     = GlobalKey<FormState>();
  final _emailCtrl   = TextEditingController();

  // state variables
  bool    _isLoading  = false;
  bool    _btnPressed = false;
  bool    _sent       = false;
  String? _error;

  // entrance animation
  late final AnimationController _entranceCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;


  /// I build the email field with label and validation.
  ///
  /// :returns: the widget for the email field
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'E-MAIL',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize:   15,
            color:      _kLabel,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller:   _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          validator:    _validateEmail,
          style: GoogleFonts.inter(fontSize: 16, color: Colors.black),
          decoration: InputDecoration(
            hintText:  'seu@gmail.com.br',
            hintStyle: GoogleFonts.inter(fontSize: 16, color: _kHint),
            filled:    true,
            fillColor: _kFieldBg,
            prefixIcon: const Icon(Icons.mail_outline, color: _kHint, size: 22),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15, horizontal: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:   const BorderSide(color: _kFieldBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:   const BorderSide(color: Colors.black),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:   const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:   const BorderSide(color: Colors.red),
            ),
            errorStyle: GoogleFonts.inter(fontSize: 12),
          ),
        ),
      ],
    );
  }


  /// I submit the forgot password form.
  ///
  /// :returns: void
  Future<void> _submit() async {

    // validate form before submitting
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // set loading state and clear previous error
    setState(() { _isLoading = true; _error = null; });

    // try to send the password reset email
    try {
      await _authService.sendPasswordResetEmail(_emailCtrl.text.trim());

      // email sent: switch to success state
      if (mounted) setState(() => _sent = true);
    }

    // authentication error: display the error message
    on AuthException catch (e) {
      setState(() => _error = e.message);
    }

    // infrastructure error: display the error message
    on InfrastructureException {
      setState(
        () => _error = ('Ocorreu um erro inesperado. '
                        'Tente novamente em alguns minutos.'),
      );
    }

    // any other error: display a generic error message
    catch (_) {
      setState(
        () => _error = ('Ocorreu um erro inesperado. '
                        'Tente novamente em alguns minutos.'),
      );
    }

    // reset loading state
    finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  /// I validate the email field.
  ///
  /// :param email: the email to validate
  ///
  /// :returns: an error message if validation fails, or null if it succeeds
  String? _validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) return 'Informe o e-mail';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }


  /// I build the forgot password page widget tree.
  ///
  /// :param context: the build context
  ///
  /// :returns: the forgot password page widget tree
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 37),
              child: _sent ? _buildSuccessState() : _buildFormState(),
            ),
          ),
        ),
      ),
    );
  }


  /// I build the form state (before email is sent).
  ///
  /// :returns: the form widget
  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 49),

          // --- back to login ---
          GestureDetector(
            onTap: () => context.go('/login'),
            child: Opacity(
              opacity: 0.7,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_back,
                    size:  18,
                    color: _kLabel,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Voltar ao Login',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize:   15,
                      color:      _kLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 44),

          // --- title ---
          Text(
            'Recuperar Senha',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize:   24,
              height:     29 / 24,
              color:      const Color(0xFF040404),
            ),
          ),
          const SizedBox(height: 28),

          // --- subtitle ---
          Text(
            'Insira seu e-mail e enviaremos um link '
            'para redefinir sua senha',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize:   15,
              height:     18 / 15,
              color:      _kBody,
            ),
          ),
          const SizedBox(height: 28),

          // --- email field ---
          _buildEmailField(),
          const SizedBox(height: 24),

          // --- error banner ---
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve:    Curves.easeOut,
            child: _error == null
                ? const SizedBox.shrink()
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12,
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color:        const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFCDD2)),
                    ),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color:    const Color(0xFFC62828),
                      ),
                    ),
                  ),
          ),

          // --- send link button ---
          GestureDetector(
            onTapDown:  (_) => setState(() => _btnPressed = true),
            onTapUp:    (_) {
              setState(() => _btnPressed = false);
              if (!_isLoading) _submit();
            },
            onTapCancel: () => setState(() => _btnPressed = false),
            child: AnimatedScale(
              scale:    _btnPressed ? 0.97 : 1.0,
              duration: const Duration(milliseconds: 80),
              child: Container(
                width:  double.infinity,
                height: 58,
                decoration: BoxDecoration(
                  color:        Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: _isLoading
                    ? const SizedBox(
                        width:  24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color:       Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'ENVIAR LINK',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize:   20,
                          color:      Colors.white,
                        ),
                      ),
              ),
            ),
          ),

        ],
      ),
    );
  }


  /// I build the success state (after email is sent).
  ///
  /// :returns: the success widget
  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        const SizedBox(height: 120),

        // --- success icon ---
        Container(
          width:  72,
          height: 72,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: Colors.white,
            size:  36,
          ),
        ),
        const SizedBox(height: 32),

        // --- success title ---
        Text(
          'Link enviado!',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize:   24,
            color:      const Color(0xFF040404),
          ),
        ),
        const SizedBox(height: 16),

        // --- success message ---
        Text(
          'Verifique sua caixa de entrada e siga as '
          'instruções para redefinir sua senha.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w400,
            fontSize:   15,
            height:     18 / 15,
            color:      _kBody,
          ),
        ),
        const SizedBox(height: 40),

        // --- back to login button ---
        GestureDetector(
          onTap: () => context.go('/login'),
          child: Container(
            width:  double.infinity,
            height: 58,
            decoration: BoxDecoration(
              color:        Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              'VOLTAR AO LOGIN',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize:   20,
                color:      Colors.white,
              ),
            ),
          ),
        ),

      ],
    );
  }


  /// I clean up controllers when the widget is disposed.
  ///
  /// :returns: void
  @override
  void dispose() {
    _entranceCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }


  /// I initialize the state of this widget.
  ///
  /// Returns void.
  @override
  void initState() {
    super.initState();

    // define entrance animation
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    // define fade animation
    _fadeAnim = CurvedAnimation(
      parent: _entranceCtrl,
      curve:  Curves.easeOut,
    );

    // define slide animation
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));

    // start entrance animation
    _entranceCtrl.forward();
  }
}
