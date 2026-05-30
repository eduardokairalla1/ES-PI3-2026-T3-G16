// Eduardo Kairalla - 24024241

// Page where the user sets a new password after clicking the reset link.

// --- IMPORTS ---
import 'package:mesclainvest/core/exceptions/auth.dart';
import 'package:mesclainvest/core/exceptions/infrastructure.dart';
import 'package:mesclainvest/core/services/auth.dart';
import 'package:mesclainvest/pages/auth/widgets/auth_constants.dart';
import 'package:mesclainvest/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// --- CONSTANTS ---

// --- CODE ---

/// I display the reset password screen where the user sets a new password after clicking the reset link.
class ResetPasswordPage extends StatefulWidget {
  final String oobCode;

  const ResetPasswordPage({super.key, required this.oobCode});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

/// State for ResetPasswordPage.
class _ResetPasswordPageState extends State<ResetPasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _authService  = AuthService();

  bool _isLoading    = false;
  bool _showPassword = false;
  bool _showConfirm  = false;
  bool _done         = false;
  String? _error;

  late final AnimationController _entranceCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  /// I validate the new password field against strength requirements.
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Informe a nova senha';
    if (value.length < 8) return 'Mínimo de 8 caracteres';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Inclua ao menos uma letra maiúscula';
    }
    if (!value.contains(RegExp(r'[0-9]'))) return 'Inclua ao menos um número';
    if (!value.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{};:"\\|,.<>\/?`~]'))) {
      return 'Inclua ao menos um caractere especial';
    }
    return null;
  }

  /// I validate that the confirm password field matches the new password.
  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Confirme a senha';
    if (value != _passwordCtrl.text) return 'As senhas não coincidem';
    return null;
  }

  /// I submit the new password to Firebase and transition to the success state on success.
  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _authService.confirmPasswordReset(widget.oobCode, _passwordCtrl.text);
      if (mounted) setState(() => _done = true);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } on InfrastructureException {
      setState(() => _error = 'Ocorreu um erro inesperado. Tente novamente.');
    } catch (_) {
      setState(() => _error = 'Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // invalid link — oobCode missing from URL
    if (widget.oobCode.isEmpty) {
      return _buildInvalidLink();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 37),
              child: _done ? _buildSuccessState() : _buildFormState(),
            ),
          ),
        ),
      ),
    );
  }

  /// I build the password entry form with two password fields and a submit button.
  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 49),

          // back to login
          GestureDetector(
            onTap: () => context.go('/login'),
            child: Opacity(
              opacity: 0.7,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back, size: 18, color: kAuthLabel),
                  const SizedBox(width: 6),
                  Text(
                    'Voltar ao Login',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: kAuthLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 44),

          Text(
            'Nova Senha',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Escolha uma senha forte para proteger sua conta.',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 15,
              height: 18 / 15,
              color: kAuthBody,
            ),
          ),
          const SizedBox(height: 28),

          // password field
          _buildPasswordField(
            label: 'NOVA SENHA',
            controller: _passwordCtrl,
            show: _showPassword,
            onToggle: () => setState(() => _showPassword = !_showPassword),
            validator: _validatePassword,
          ),
          const SizedBox(height: 16),

          // confirm field
          _buildPasswordField(
            label: 'CONFIRMAR SENHA',
            controller: _confirmCtrl,
            show: _showConfirm,
            onToggle: () => setState(() => _showConfirm = !_showConfirm),
            validator: _validateConfirm,
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
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.red.shade800,
                      ),
                    ),
                  ),
          ),

          // submit button
          AppButton(
            label: 'REDEFINIR SENHA',
            size: AppButtonSize.large,
            isLoading: _isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  /// I build a styled password input field with a visibility toggle.
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool show,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
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
          controller: controller,
          obscureText: !show,
          validator: validator,
          style: GoogleFonts.inter(fontSize: 16, color: Colors.black),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: GoogleFonts.inter(fontSize: 16, color: kAuthHint),
            filled: true,
            fillColor: kAuthFieldBg,
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: kAuthHint,
              size: 22,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                show
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: kAuthHint,
                size: 22,
              ),
              onPressed: onToggle,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: kAuthFieldBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.black),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.red),
            ),
            errorStyle: GoogleFonts.inter(fontSize: 12),
          ),
        ),
      ],
    );
  }

  /// I build the success state shown after the password has been successfully reset.
  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 120),
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_open_outlined,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Senha redefinida!',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Sua senha foi alterada com sucesso.\nFaça login com a nova senha.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w400,
            fontSize: 15,
            height: 18 / 15,
            color: kAuthBody,
          ),
        ),
        const SizedBox(height: 40),
        AppButton(
          label: 'IR PARA O LOGIN',
          size: AppButtonSize.large,
          onPressed: () => context.go('/login'),
        ),
      ],
    );
  }

  /// I build the invalid link error state shown when the oobCode is missing or expired.
  Widget _buildInvalidLink() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 37),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 120),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.link_off,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Link inválido',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Este link é inválido ou já foi utilizado.\nSolicite um novo link de recuperação.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  height: 18 / 15,
                  color: kAuthBody,
                ),
              ),
              const SizedBox(height: 40),
              AppButton(
                label: 'SOLICITAR NOVO LINK',
                size: AppButtonSize.large,
                onPressed: () => context.go('/forgot-password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
