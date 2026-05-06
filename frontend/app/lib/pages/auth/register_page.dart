/// Eduardo Kairalla - 24024241

/// Register page.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/core/exceptions/auth.dart';
import 'package:mesclainvest/core/exceptions/infrastructure.dart';
import 'package:mesclainvest/core/services/auth.dart';
import 'package:mesclainvest/pages/auth/widgets/auth_constants.dart';
import 'package:mesclainvest/pages/auth/widgets/input_formatters.dart';


// --- CODE ---

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
class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {

  // define controllers for text fields
  final _authService       = AuthService();
  final _formKey           = GlobalKey<FormState>();
  final _fullNameCtrl      = TextEditingController();
  final _emailCtrl         = TextEditingController();
  final _cpfCtrl           = TextEditingController();
  final _phoneCtrl         = TextEditingController();
  final _passwordCtrl      = TextEditingController();
  final _passwordFocusNode = FocusNode();

  // define state variables
  bool      _isLoading      = false;
  bool      _showPassword   = false;
  bool      _btnPressed     = false;
  String?   _error;
  DateTime? _birthDate;
  String?   _birthDateError;

  // password requirements
  bool get _hasMinLength => _passwordCtrl.text.length >= 8;
  bool get _hasUppercase => _passwordCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _hasNumber    => _passwordCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial   => _passwordCtrl.text.contains(
    RegExp(r'[!@#\$%^&*()_+\-=\[\]{};:"\\|,.<>\/?`~]'),
  );
  bool get _passwordValid =>
      _hasMinLength && _hasUppercase && _hasNumber && _hasSpecial;
  bool _passwordHasFocus = false;
  bool get _showChecker => _passwordHasFocus;

  // entrance animation
  late final AnimationController _entranceCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;


  /// I build the birth date field with a custom input and error display.
  ///
  /// :returns: the widget for the birth date field
  Widget _buildDateField() {

    final text = _birthDate == null
        ? null
        : '${_birthDate!.day.toString().padLeft(2, '0')}/'
          '${_birthDate!.month.toString().padLeft(2, '0')}/'
          '${_birthDate!.year}';

    final hasError = _birthDateError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATA DE NASCIMENTO',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize:   15,
            color:      kAuthLabel,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isLoading ? null : _pickDate,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color:        kAuthFieldBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasError ? Colors.red : kAuthFieldBorder,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.cake_outlined, color: kAuthHint, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text ?? 'DD/MM/AAAA',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color:    text != null ? Colors.black : kAuthHint,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  color: kAuthHint,
                  size:  18,
                ),
              ],
            ),
          ),
        ),

        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              _birthDateError!,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.red),
            ),
          ),
      ],
    );
  }


  /// I build a custom text field with a label, icon, and validation.
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
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
            fontSize: 15,
            color: kAuthLabel,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller:       controller,
          keyboardType:     keyboardType,
          inputFormatters:  inputFormatters,
          obscureText:      obscureText,
          validator:        validator,
          style: GoogleFonts.inter(fontSize: 16, color: Colors.black),
          decoration: InputDecoration(
            hintText:  hint,
            hintStyle: GoogleFonts.inter(fontSize: 16, color: kAuthHint),
            filled:    true,
            fillColor: kAuthFieldBg,
            prefixIcon: Icon(icon, color: kAuthHint, size: 22),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:   const BorderSide(color: kAuthFieldBorder),
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


  /// I build a password requirement item with an icon and text.
  Widget _buildReq(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve:    Curves.easeOut,
            width:  18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: met ? const Color(0xFF4CAF50) : Colors.transparent,
              border: met
                  ? null
                  : Border.all(
                      color: const Color(0xFFBDBDBD),
                      width: 1.5,
                    ),
            ),
            child: met
                ? const Icon(Icons.check, size: 11, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: GoogleFonts.inter(
              fontSize:   12,
              color:      met ? const Color(0xFF388E3C) : const Color(0xFF9E9E9E),
              fontWeight: met ? FontWeight.w600 : FontWeight.w400,
            ),
            child: Text(text),
          ),
        ],
      ),
    );
  }


  String? _calcBirthDateError() {
    if (_birthDate == null) return 'Informe sua data de nascimento';
    final today = DateTime.now();
    var age = today.year - _birthDate!.year;
    if (today.month < _birthDate!.month ||
        (today.month == _birthDate!.month && today.day < _birthDate!.day)) {
      age--;
    }
    if (age < 18) return 'Você deve ter pelo menos 18 anos para se cadastrar';
    return null;
  }


  void _onFocusChanged() {
    if (mounted) {
      setState(() => _passwordHasFocus = _passwordFocusNode.hasFocus);
    }
  }


  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && mounted) {
      setState(() {
        _birthDate = picked;
        _birthDateError = null;
      });
    }
  }


  Future<void> _submit() async {
    setState(() { _isLoading = true; _error = null; });

    try {
      final d = _birthDate!;
      final birthIso = (
        '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}'
      );

      await _authService.register(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
        _fullNameCtrl.text.trim(),
        _cpfCtrl.text,
        _phoneCtrl.text,
        birthIso,
      );

      // Carrega o perfil no AppState para que o nome apareça corretamente no Dashboard.
      // O register() já autentica o usuário, então getProfile() funcionará imediatamente.
      await AppState.instance.loadProfile(_authService);

      if (mounted) context.go('/dashboard');
    }
    on AuthException catch (e) {
      setState(() => _error = e.message);
    }
    on InfrastructureException {
      setState(
        () => _error = ('Ocorreu um erro inesperado. '
                        'Tente novamente em alguns minutos.')
      );
    }
    catch (_) {
      setState(
        () => _error = ('Ocorreu um erro inesperado. '
                        'Tente novamente em alguns minutos.')
      );
    }
    finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  String? _validateCpf(String? cpf) {
    if (cpf == null || cpf.isEmpty) return 'Informe o CPF';
    final d = cpf.replaceAll(RegExp(r'\D'), '');
    if (d.length != 11) return 'CPF deve ter 11 dígitos';
    if (RegExp(r'^(\d)\1{10}$').hasMatch(d)) return 'CPF inválido';

    var sum = 0;
    for (var i = 0; i < 9; i++) { sum += int.parse(d[i]) * (10 - i); }
    var rem = (sum * 10) % 11;
    if (rem >= 10) rem = 0;
    if (rem != int.parse(d[9])) return 'CPF inválido';

    sum = 0;
    for (var i = 0; i < 10; i++) { sum += int.parse(d[i]) * (11 - i); }
    rem = (sum * 10) % 11;
    if (rem >= 10) rem = 0;
    if (rem != int.parse(d[10])) return 'CPF inválido';

    return null;
  }


  String? _validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) return 'Informe o e-mail';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }


  String? _validateName(String? name) {
    if (name == null || name.trim().isEmpty) return 'Informe seu nome completo';
    if (name.trim().split(' ').length < 2) return 'Informe nome e sobrenome';
    return null;
  }


  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) return 'Informe a senha';
    if (!_passwordValid) return 'A senha não atende todos os requisitos';
    return null;
  }


  String? _validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) return 'Informe o telefone';
    final d = phone.replaceAll(RegExp(r'\D'), '');
    if (d.length < 10 || d.length > 11) return 'Telefone inválido';
    return null;
  }


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

                    Text(
                      'Mescla\nInvest',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 48,
                        height:    1.1,
                        color:     Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Crie sua conta e comece a investir',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize:   15,
                        color:      kAuthSubtitle,
                      ),
                    ),
                    const SizedBox(height: 28),

                    _buildField(
                      controller:     _fullNameCtrl,
                      label:          'NOME COMPLETO',
                      hint:           'Seu nome completo',
                      icon:           Icons.person_outline,
                      keyboardType:   TextInputType.name,
                      validator:      _validateName,
                    ),
                    const SizedBox(height: 24),

                    _buildField(
                      controller:   _emailCtrl,
                      label:        'E-MAIL',
                      hint:         'seu@gmail.com.br',
                      icon:         Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator:    _validateEmail,
                    ),
                    const SizedBox(height: 24),

                    _buildField(
                      controller:      _cpfCtrl,
                      label:           'CPF',
                      hint:            '000.000.000-00',
                      icon:            Icons.badge_outlined,
                      keyboardType:    TextInputType.number,
                      inputFormatters: [CpfFormatter()],
                      validator:       _validateCpf,
                    ),
                    const SizedBox(height: 24),

                    _buildDateField(),
                    const SizedBox(height: 24),

                    _buildField(
                      controller:      _phoneCtrl,
                      label:           'TELEFONE CELULAR',
                      hint:            '(11) 99999-9999',
                      icon:            Icons.phone_outlined,
                      keyboardType:    TextInputType.phone,
                      inputFormatters: [PhoneFormatter()],
                      validator:       _validatePhone,
                    ),
                    const SizedBox(height: 24),

                    // password field with checklist
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SENHA',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize:   15,
                            color:      kAuthLabel,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller:  _passwordCtrl,
                          focusNode:   _passwordFocusNode,
                          obscureText: !_showPassword,
                          validator:   _validatePassword,
                          onChanged:   (_) => setState(() {}),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color:    Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText:  'Mín. 8 caracteres',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 16,
                              color:    kAuthHint,
                            ),
                            filled:    true,
                            fillColor: kAuthFieldBg,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: kAuthHint,
                              size:  22,
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () => setState(
                                () => _showPassword = !_showPassword,
                              ),
                              child: Icon(
                                _showPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: kAuthHint,
                                size:  22,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 16,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide:   const BorderSide(color: kAuthFieldBorder),
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

                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve:    Curves.easeOut,
                          child: _showChecker
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 12, left: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildReq('Mínimo 8 caracteres', _hasMinLength),
                                      _buildReq('Uma letra maiúscula (A–Z)', _hasUppercase),
                                      _buildReq('Um número (0–9)', _hasNumber),
                                      _buildReq('Um caractere especial (!@#\$...)', _hasSpecial),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // error banner
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: _error == null
                          ? const SizedBox.shrink()
                          : Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
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
                                  color: const Color(0xFFC62828),
                                ),
                              ),
                            ),
                    ),

                    // register button
                    GestureDetector(
                      onTapDown: (_) => setState(() => _btnPressed = true),
                      onTapUp: (_) {
                        setState(() => _btnPressed = false);
                        if (_isLoading) return;
                        final bdError = _calcBirthDateError();
                        final formOk  = _formKey.currentState?.validate() ?? false;
                        setState(() => _birthDateError = bdError);
                        if (formOk && bdError == null) _submit();
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
                                  'CADASTRAR',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w800,
                                    fontSize:   20,
                                    color:      Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Já possui conta? ',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize:   15,
                            color:      kAuthBody,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            'Fazer Login',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize:   20,
                              color:      kAuthBody,
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


  @override
  void dispose() {
    _entranceCtrl.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _cpfCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim  = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));
    _entranceCtrl.forward();
    _passwordFocusNode.addListener(_onFocusChanged);
  }
}
