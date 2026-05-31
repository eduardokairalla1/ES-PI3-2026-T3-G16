// Eduardo Kairalla - 24024241

// Page where the user scans a QR code and confirms the first TOTP code
// to enable 2FA on their account.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/core/exceptions/auth.dart';
import 'package:mesclainvest/core/services/auth.dart';
import 'package:mesclainvest/pages/auth/widgets/auth_constants.dart';
import 'package:qr_flutter/qr_flutter.dart';


/// I display the 2FA setup screen where the user scans a QR code and confirms the first TOTP code.
class Setup2FAPage extends StatefulWidget {
  const Setup2FAPage({super.key});

  @override
  State<Setup2FAPage> createState() => _Setup2FAPageState();
}


/// State for Setup2FAPage.
class _Setup2FAPageState extends State<Setup2FAPage>
    with SingleTickerProviderStateMixin {

  final _authService = AuthService();
  final _codeCtrl    = TextEditingController();

  String? _otpauthUri;
  bool    _isLoadingQr   = true;
  bool    _isConfirming  = false;
  bool    _btnPressed    = false;
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
    _loadQrCode();
  }


  @override
  void dispose() {
    _entranceCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }


  /// I load the OTP auth URI from the server and display the QR code.
  Future<void> _loadQrCode() async {
    try {
      final uri = await _authService.setup2FA();
      if (mounted) setState(() { _otpauthUri = uri; _isLoadingQr = false; });
    }
    catch (_) {
      if (mounted) {
        setState(() {
          _error       = 'Erro ao gerar QR code. Tente novamente.';
          _isLoadingQr = false;
        });
      }
    }
  }


  /// I confirm 2FA setup by validating the TOTP code and enabling 2FA on the account.
  Future<void> _confirm() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Digite o código de 6 dígitos');
      return;
    }

    setState(() { _isConfirming = true; _error = null; });

    try {
      await _authService.confirmSetup2FA(code);
      AppState.instance.updateProfileLocally(twoFaEnabled: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Autenticação 2FA ativada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/profile');
      }
    }
    on AuthException catch (e) {
      setState(() => _error = e.message);
    }
    catch (_) {
      setState(() => _error = 'Ocorreu um erro inesperado. Tente novamente.');
    }
    finally {
      if (mounted) setState(() => _isConfirming = false);
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 37),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 49),

                  // back
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: Opacity(
                      opacity: 0.7,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back, size: 18, color: kAuthLabel),
                          const SizedBox(width: 6),
                          Text(
                            'Voltar',
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

                  Text(
                    'Ativar 2FA',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize:   24,
                      color:      const Color(0xFF040404),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Escaneie o QR code com um app autenticador '
                    '(Google Authenticator, Authy etc.) e confirme '
                    'com o código gerado.',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize:   15,
                      height:     1.4,
                      color:      kAuthBody,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // QR code area
                  Center(
                    child: _isLoadingQr
                        ? const SizedBox(
                            width:  200,
                            height: 200,
                            child:  Center(
                              child: CircularProgressIndicator(color: Colors.black),
                            ),
                          )
                        : _otpauthUri != null
                            ? Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:        Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.black.withValues(alpha: 0.12),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:      Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 12,
                                      offset:     const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: QrImageView(
                                  data:    _otpauthUri!,
                                  version: QrVersions.auto,
                                  size:    200,
                                ),
                              )
                            : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 32),

                  // code field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CÓDIGO DE CONFIRMAÇÃO',
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

                  // confirm button
                  GestureDetector(
                    onTapDown:   (_) => setState(() => _btnPressed = true),
                    onTapUp:     (_) {
                      setState(() => _btnPressed = false);
                      if (!_isConfirming && _otpauthUri != null) _confirm();
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
                        child: _isConfirming
                            ? const SizedBox(
                                width:  24,
                                height: 24,
                                child:  CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'ATIVAR 2FA',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w800,
                                  fontSize:   20,
                                  color:      Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
