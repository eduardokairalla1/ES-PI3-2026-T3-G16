// --- Login page ---

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/core/exceptions/auth.dart';
import 'package:mesclainvest/core/exceptions/infrastructure.dart';
import 'package:mesclainvest/core/services/auth.dart';


// --- CONSTANTS ---
const _kFieldBg     = Color(0xFFF8F8F8);
const _kFieldBorder = Color(0xFFD4D4D4);
const _kLabel       = Color(0xFF424242);
const _kHint        = Color(0xFFA4A2A2);
const _kSubtitle    = Color(0xFFAAAAAA);
const _kBottom      = Color(0xFF454545);


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
class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  // define controllers for text fields
  final _authService      = AuthService();
  final _formKey          = GlobalKey<FormState>();
  final _emailCtrl        = TextEditingController();
  final _passwordCtrl     = TextEditingController();

  // define state variables
  bool    _isLoading    = false;
  bool    _showPassword = false;
  bool    _btnPressed   = false;
  String? _error;

  // entrance animation
  late final AnimationController _entranceCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;


  /// I build a custom text field with a label, icon, and validation.
  ///
  /// :param controller: the text editing controller for the field
  /// :param label: the label text to display above the field
  /// :param hint: the placeholder text to display inside the field
  /// :param icon: the icon to display on the left side of the field
  /// :param keyboardType: the type of keyboard to show for this field
  /// :param obscureText: whether to obscure the text (for passwords)
  /// :param suffixIcon: an optional widget to display on the right side
  /// :param validator: an optional function to validate the field's value
  ///
  /// :returns: the widget for the custom text field
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize:   15,
            color:      _kLabel,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller:   controller,
          keyboardType: keyboardType,
          obscureText:  obscureText,
          validator:    validator,
          style: GoogleFonts.inter(fontSize: 16, color: Colors.black),
          decoration: InputDecoration(
            hintText:  hint,
            hintStyle: GoogleFonts.inter(fontSize: 16, color: _kHint),
            filled:    true,
            fillColor: _kFieldBg,
            prefixIcon: Icon(icon, color: _kHint, size: 22),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 16,
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


  /// I submit the login form.
  /// 
  /// returns: void
  Future<void> _submit() async {

    // set loading state and clear previous error
    setState(() { _isLoading = true; _error = null; });

    // try to sign in the user
    try {
      await _authService.signIn(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );

      // load user profile into global app state
      await AppState.instance.loadProfile(_authService);

      // login successful: navigate to the dashboard page
      if (mounted) context.go('/dashboard');
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

    // email is null or empty: return error message
    if (email == null || email.trim().isEmpty) return 'Informe o e-mail';

    // email format is invalid: return error message
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email.trim())) {
      return 'E-mail inválido';
    }

    // validation passed: return null
    return null;
  }


  /// I validate the password field.
  ///
  /// :param password: the password to validate
  ///
  /// :returns: an error message if validation fails, or null if it succeeds
  String? _validatePassword(String? password) {

    // password is null or empty: return error message
    if (password == null || password.isEmpty) return 'Informe a senha';

    // validation passed: return null
    return null;
  }


  /// I build the login page widget tree.
  ///
  /// :param context: the build context
  ///
  /// :returns: the login page widget tree
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 37),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    const SizedBox(height: 49),

                    // --- title ---
                    Text(
                      'Mescla\nInvest',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize:   48,
                        height:     1.1,
                        color:      Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- subtitle ---
                    Text(
                      'Entre na sua conta para continuar.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize:   15,
                        color:      _kSubtitle,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- e-mail ---
                    _buildField(
                      controller:   _emailCtrl,
                      label:        'E-MAIL',
                      hint:         'seu@gmail.com.br',
                      icon:         Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator:    _validateEmail,
                    ),
                    const SizedBox(height: 24),

                    // --- password ---
                    _buildField(
                      controller:  _passwordCtrl,
                      label:       'SENHA',
                      hint:        'Sua senha',
                      icon:        Icons.lock_outline,
                      obscureText: !_showPassword,
                      validator:   _validatePassword,
                      suffixIcon: GestureDetector(
                        onTap: () =>
                            setState(() => _showPassword = !_showPassword),
                        child: Icon(
                          _showPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: _kHint,
                          size:  22,
                        ),
                      ),
                    ),
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
                                horizontal: 16,
                                vertical:   12,
                              ),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color:        const Color(0xFFFFF0F0),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFFCDD2),
                                ),
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

                    // --- login button ---
                    GestureDetector(
                      onTapDown: (_) =>
                          setState(() => _btnPressed = true),
                      onTapUp: (_) {
                        setState(() => _btnPressed = false);
                        if (_isLoading) return;
                        if (_formKey.currentState?.validate() ?? false) {
                          _submit();
                        }
                      },
                      onTapCancel: () =>
                          setState(() => _btnPressed = false),
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
                                  'ENTRAR',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w800,
                                    fontSize:   20,
                                    color:      Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- forgot password ---
                    GestureDetector(
                      onTap: () => context.go('/forgot-password'),
                      child: Text(
                        'Esqueci minha senha',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize:   15,
                          color:      _kBottom,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- no account yet ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Não possui conta? ',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize:   15,
                            color:      _kBottom,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: Text(
                            'Cadastrar',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize:   20,
                              color:      _kBottom,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  /// I clean up the controllers when the widget is disposed.
  ///
  /// :returns: void
  @override
  void dispose() {
    _entranceCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }


  /// I initialize the state of this widget.
  ///
  /// Returns void.
  @override
  void initState() {

    // call super method
    super.initState();

    // define entrance animation
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    // define fade animation
    _fadeAnim  = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);

    // define slide animation
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));

    // start entrance animation
    _entranceCtrl.forward();
  }
}
