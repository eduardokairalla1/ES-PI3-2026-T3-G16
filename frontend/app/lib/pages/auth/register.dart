// --- Register page ---

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
const _kSubtitle    = Color(0xFFAAAAAA);
const _kBottom      = Color(0xFF454545);


/// --- CODE ---

/// I format the CPF input as the user types, adding dots and dashes.
class _CpfFormatter extends TextInputFormatter {

  /// I format the CPF input by removing non-digit characters and adding
  /// dots after the 3rd and 6th digits, and a dash after the 9th digit.
  /// 
  /// :param oldValue: the previous text editing value
  /// :param newValue: the new text editing value
  ///
  /// :returns: a new text editing value with the formatted CPF
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {

    // remove all non-digit characters from the input
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();

    // iterate over the digits
    for (var i = 0; i < digits.length && i < 11; i++) {

      // add dots after the 3rd and 6th digits
      if (i == 3 || i == 6) buf.write('.');

      // add a dash after the 9th digit
      if (i == 9) buf.write('-');

      // add the current digit to the buffer
      buf.write(digits[i]);
    }

    // convert the buffer to a string to get the formatted CPF
    final out = buf.toString();

    // return a new TextEditingValue with the formatted CPF
    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: out.length),
    );
  }
}


/// I format the phone number input as the user types,
/// adding parentheses, spaces, and dashes.
class _PhoneFormatter extends TextInputFormatter {

  /// I format the phone number input by removing non-digit characters
  /// and adding parentheses around the area code, a space after the area code,
  /// and a dash before the last four digits.
  /// 
  /// :param oldValue: the previous text editing value
  /// :param newValue: the new text editing value
  ///
  /// :returns: a new text editing value with the formatted phone number
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {

    // remove all non-digit characters from the input
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();

    // iterate over the digits
    for (var i = 0; i < digits.length && i < 11; i++) {

      // it's the first digit: add an opening parenthesis before it
      if (i == 0) buf.write('(');

      // it's the second digit: add a closing parenthesis and a space before it
      if (i == 2) buf.write(') ');

      // it's the seventh digit (for 11-digit numbers) or the sixth digit
      if (i == 7) buf.write('-');

      // add the current digit to the buffer
      buf.write(digits[i]);
    }

    // convert the buffer to a string to get the formatted phone number
    final out = buf.toString();

    // return a new TextEditingValue with the formatted phone number
    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: out.length),
    );
  }
}


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

    // format the selected birth date as DD/MM/YYYY or
    // show placeholder if not selected
    final text = _birthDate == null
        ? null
        : '${_birthDate!.day.toString().padLeft(2, '0')}/'
          '${_birthDate!.month.toString().padLeft(2, '0')}/'
          '${_birthDate!.year}';

    // check if there is an error to determine the border color
    final hasError = _birthDateError != null;

    // build the field with label, custom input, and error message
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATA DE NASCIMENTO',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize:   15,
            color:      _kLabel,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isLoading ? null : _pickDate,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color:        _kFieldBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasError ? Colors.red : _kFieldBorder,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.cake_outlined, color: _kHint, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text ?? 'DD/MM/AAAA',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color:    text != null ? Colors.black : _kHint,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  color: _kHint,
                  size:  18,
                ),
              ],
            ),
          ),
        ),

        // there is an error: display the error message below the field
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
  ///
  /// :param controller: the text editing controller for the field
  /// :param label: the label text to display above the field
  /// :param hint: the placeholder text to display inside the field
  /// :param icon: the icon to display on the left side of the field
  /// :param keyboardType: the type of keyboard to show for this field
  /// :param inputFormatters: a list of input formatters to apply to the field
  /// :param obscureText: whether to obscure the text (for passwords)
  /// :param suffixIcon: an optional widget to display on the right
  ///                    side of the field
  /// :param validator: an optional function to validate the field's value
  ///
  /// :returns: the widget for the custom text field
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
            color: _kLabel,
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


  /// I build a password requirement item with an icon and text.
  /// 
  /// :param text: the description of the requirement
  /// :param met: whether the requirement is met or not
  ///
  /// :returns: the widget for the password requirement item
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


  /// I calculate the error message for the birth date
  /// field based on the selected date.
  ///
  /// :returns: an error message if the birth date is invalid,
  /// or null if it is valid
  String? _calcBirthDateError() {

    // birth date not selected: return error message
    if (_birthDate == null) return 'Informe sua data de nascimento';
    
    // calculate age based on birth date and current date
    final today = DateTime.now();

    // calculate age and check if user is at least 18 years old
    var age = today.year - _birthDate!.year;

    // birth date has not occurred yet this year: subtract one from age
    if (today.month < _birthDate!.month ||
        (today.month == _birthDate!.month && today.day < _birthDate!.day)) {
      age--;
    }

    // user is under 18 years old: return error message
    if (age < 18) return 'Você deve ter pelo menos 18 anos para se cadastrar';

    // birth date is valid: return null
    return null;
  }


  /// I handle changes in the password field focus
  /// to show/hide the password requirements checklist.
  /// 
  /// Returns void.
  void _onFocusChanged() {

    // password field has focus: show the checklist
    if (mounted) {
      setState(() => _passwordHasFocus = _passwordFocusNode.hasFocus);
    }
  }


  /// I pick a date from the date picker.
  /// 
  /// :returns: void
  Future<void> _pickDate() async {

    // get current date
    final now = DateTime.now();

    // show date picker
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      locale: const Locale('pt', 'BR'),
    );

    // date was picked and the widget is still mounted:
    // update the birth date state
    if (picked != null && mounted) {
      setState(() {
        _birthDate = picked;
        _birthDateError = null;
      });
    }
  }


  /// I submit the register form.
  ///
  /// returns: void
  Future<void> _submit() async {

    // set loading state and clear previous error
    setState(() { _isLoading = true; _error = null; });

    // try to register the user
    try {

      // convert birth date to ISO format
      final d = _birthDate!;
      final birthIso = (
        '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}'
      );

      // call register method in auth service
      await _authService.register(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
        _fullNameCtrl.text.trim(),
        _cpfCtrl.text,
        _phoneCtrl.text,
        birthIso,
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


  /// I validate the CPF field.
  ///
  /// :param cpf: the CPF to validate
  ///
  /// :returns: an error message if the validation fails, or null if it succeeds
  String? _validateCpf(String? cpf) {

    // cpf is null or empty: return error message
    if (cpf == null || cpf.isEmpty) return 'Informe o CPF';

    // remove non-digit characters and check length and repeated digits
    final d = cpf.replaceAll(RegExp(r'\D'), '');

    // CPF must have 11 digits: return error message
    if (d.length != 11) return 'CPF deve ter 11 dígitos';

    // CPF with all digits the same is invalid: return error message
    if (RegExp(r'^(\d)\1{10}$').hasMatch(d)) return 'CPF inválido';

    // first check digit
    var sum = 0;

    // calculate weighted sum of first 9 digits
    for (var i = 0; i < 9; i++) { sum += int.parse(d[i]) * (10 - i); }

    // calculate first check digit and compare with 10th digit
    var rem = (sum * 10) % 11;

    // remainder is 10 or greater: set to 0
    if (rem >= 10) rem = 0;

    // check digit does not match: return error message
    if (rem != int.parse(d[9])) return 'CPF inválido';

    // second check digit
    sum = 0;

    // calculate weighted sum of first 10 digits
    for (var i = 0; i < 10; i++) { sum += int.parse(d[i]) * (11 - i); }

    // calculate second check digit and compare with 11th digit
    rem = (sum * 10) % 11;

    // remainder is 10 or greater: set to 0
    if (rem >= 10) rem = 0;

    // check digit does not match: return error message
    if (rem != int.parse(d[10])) return 'CPF inválido';

    // validation passed: return null
    return null;
  }


  /// I validate the email field.
  ///
  /// :param email: the email to validate
  ///
  /// :returns: an error message if the validation fails, or null if it succeeds
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


  /// I validate the full name field.
  ///
  /// :param name: the full name to validate
  ///
  /// :returns: an error message if the validation fails, or null if it succeeds
  String? _validateName(String? name) {

    // name is null or empty: return error message
    if (name == null || name.trim().isEmpty) return 'Informe seu nome completo';

    // name must contain at least two words: return error message
    if (name.trim().split(' ').length < 2) return 'Informe nome e sobrenome';

    // validation passed: return null    
    return null;
  }


  /// I validate the password field.
  /// 
  /// :param password: the password to validate
  ///
  /// :returns: an error message if the validation fails, or null if it succeeds
  String? _validatePassword(String? password) {

    // password is null or empty: return error message
    if (password == null || password.isEmpty) return 'Informe a senha';

    // password does not meet requirements: return error message
    if (!_passwordValid) return 'A senha não atende todos os requisitos';

    // validation passed: return null
    return null;
  }


  /// I validate the phone field.
  /// 
  /// :param phone: the phone number to validate
  ///
  /// :returns: an error message if the validation fails, or null if it succeeds
  String? _validatePhone(String? phone) {

    // phone is null or empty: return error message
    if (phone == null || phone.isEmpty) return 'Informe o telefone';

    // remove non-digit characters and check length
    final d = phone.replaceAll(RegExp(r'\D'), '');

    // phone must have 10 or 11 digits: return error message
    if (d.length < 10 || d.length > 11) return 'Telefone inválido';

    // validation passed: return null
    return null;
  }


  /// I build the register page widget tree.
  ///
  /// :param context: the build context
  ///
  /// :returns: the register page widget tree
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
                        fontSize: 48,
                        height:    1.1,
                        color:     Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- subtitle ---
                    Text(
                      'Crie sua conta e comece a investir',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize:   15,
                        color:      _kSubtitle,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- full name ---
                    _buildField(
                      controller:     _fullNameCtrl,
                      label:          'NOME COMPLETO',
                      hint:           'Seu nome completo',
                      icon:           Icons.person_outline,
                      keyboardType:   TextInputType.name,
                      validator:      _validateName,
                    ),
                    const SizedBox(height: 24),

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

                    // --- cpf ---
                    _buildField(
                      controller:      _cpfCtrl,
                      label:           'CPF',
                      hint:            '000.000.000-00',
                      icon:            Icons.badge_outlined,
                      keyboardType:    TextInputType.number,
                      inputFormatters: [_CpfFormatter()],
                      validator:       _validateCpf,
                    ),
                    const SizedBox(height: 24),

                    // --- date of birth ---
                    _buildDateField(),
                    const SizedBox(height: 24),

                    // --- phone ---
                    _buildField(
                      controller:      _phoneCtrl,
                      label:           'TELEFONE CELULAR',
                      hint:            '(11) 99999-9999',
                      icon:            Icons.phone_outlined,
                      keyboardType:    TextInputType.phone,
                      inputFormatters: [_PhoneFormatter()],
                      validator:       _validatePhone,
                    ),
                    const SizedBox(height: 24),

                    // --- password ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SENHA',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize:   15,
                            color:      _kLabel,
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
                              color:    _kHint,
                            ),
                            filled:    true,
                            fillColor: _kFieldBg,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: _kHint,
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
                                color: _kHint,
                                size:  22,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 16,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide:   const BorderSide(
                                color: _kFieldBorder
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide:   const BorderSide(
                                color: Colors.black
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide:   const BorderSide(
                                color: Colors.red
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide:   const BorderSide(
                                color: Colors.red
                              ),
                            ),
                            errorStyle: GoogleFonts.inter(fontSize: 12),
                          ),
                        ),

                        // --- password checklist ---
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve:    Curves.easeOut,
                          child: _showChecker
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    top: 12, left: 4,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildReq(
                                        'Mínimo 8 caracteres',
                                        _hasMinLength,
                                      ),
                                      _buildReq(
                                        'Uma letra maiúscula (A–Z)',
                                        _hasUppercase,
                                      ),
                                      _buildReq('Um número (0–9)', _hasNumber),
                                      _buildReq(
                                        'Um caractere especial (!@#\$...)',
                                        _hasSpecial,
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- error banner ---
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
                                border: Border.all(
                                  color: const Color(0xFFFFCDD2),
                                ),
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

                    // --- register button ---
                    GestureDetector(
                      onTapDown: (_) =>
                          setState(() => _btnPressed = true),
                      onTapUp: (_) {
                        setState(() => _btnPressed = false);
                        if (_isLoading) return;
                        final bdError = _calcBirthDateError();
                        final formOk =
                            _formKey.currentState?.validate() ?? false;
                        setState(() => _birthDateError = bdError);
                        if (formOk && bdError == null) _submit();
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

                    // --- already have an account ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Já possui conta? ',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize:   15,
                            color:      _kBottom,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            'Fazer Login',
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
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _cpfCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordFocusNode.dispose();
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

    // start entrance animation and listen to password focus changes
    _entranceCtrl.forward();
    _passwordFocusNode.addListener(_onFocusChanged);
  }
}
