/// Eduardo Kairalla - 24024241

/// Page where the user enters their TOTP code during login when 2FA is enabled.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesclainvest/core/exceptions/auth.dart';
import 'package:mesclainvest/core/exceptions/infrastructure.dart';
import 'package:mesclainvest/core/services/auth.dart';
import 'package:mesclainvest/pages/auth/widgets/auth_constants.dart';


/// I display the 2FA verification screen where the user enters their TOTP code during login.
class Verify2FAPage extends StatefulWidget {
  const Verify2FAPage({super.key});

  @override
  State<Verify2FAPage> createState() => _Verify2FAPageState();
}


/// State for Verify2FAPage.
class _Verify2FAPageState extends State<Verify2FAPage>
    with SingleTickerProviderStateMixin {

  final _authService = AuthService();
  final _codeCtrl    = TextEditingController();

  bool    _isLoading = false;
  bool    _btnPressed = false;
  String? _error;

  late final AnimationController _entranceCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;


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
  }


  @override
  void dispose() {
    _entranceCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }


  /// I submit the TOTP code to the auth service and navigate to the dashboard on success.
  Future<void> _submit() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Digite o código de 6 dígitos');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      await _authService.verify2FA(code);
      if (mounted) context.go('/dashboard');
    }
    on AuthException catch (e) {
      setState(() => _error = e.message);
    }
    on InfrastructureException {
      setState(() => _error = 'Ocorreu um erro inesperado. Tente novamente.');
    }
    catch (_) {
      setState(() => _error = 'Ocorreu um erro inesperado. Tente novamente.');
    }
    finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 37),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 49),

                  // back — cancels login and returns to login page
                  GestureDetector(
                    onTap: () => _authService.signOut(),
                    child: Opacity(
                      opacity: 0.7,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back, size: 18, color: kAuthLabel),
                          const SizedBox(width: 6),
                          Text(
                            'Cancelar',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize:   15,
                              color:      kAuthLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 44),

                  // icon
                  Container(
                    width:  56,
                    height: 56,
                    decoration: BoxDecoration(
                      color:        Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size:  28,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Verificação em\nduas etapas',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize:   24,
                      height:     1.2,
                      color:      const Color(0xFF040404),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Abra o app autenticador e insira o código de 6 dígitos.',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize:   15,
                      height:     1.4,
                      color:      kAuthBody,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // code field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CÓDIGO',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize:   15,
                          color:      kAuthLabel,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller:      _codeCtrl,
                        keyboardType:    TextInputType.number,
                        maxLength:       6,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged:       (_) => setState(() => _error = null),
                        style: GoogleFonts.inter(
                          fontSize:      20,
                          letterSpacing: 8,
                          color:         Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText:       '000000',
                          hintStyle:      GoogleFonts.inter(
                            fontSize: 20, letterSpacing: 8, color: kAuthHint,
                          ),
                          counterText:    '',
                          filled:         true,
                          fillColor:      kAuthFieldBg,
                          prefixIcon:     const Icon(
                            Icons.lock_outline, color: kAuthHint, size: 22,
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // error banner
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

                  // verify button
                  GestureDetector(
                    onTapDown:   (_) => setState(() => _btnPressed = true),
                    onTapUp:     (_) {
                      setState(() => _btnPressed = false);
                      if (!_isLoading) _submit();
                    },
                    onTapCancel: ()  => setState(() => _btnPressed = false),
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
                                child:  CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'VERIFICAR',
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
            ),
          ),
        ),
      ),
    );
  }
}
