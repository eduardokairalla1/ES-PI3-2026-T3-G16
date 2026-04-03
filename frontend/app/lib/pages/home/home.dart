// --- Home page ---
// Eduardo Kairalla - 24024241

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';


// --- CONSTANTS ---
const _kBottom = Color(0xFF454545);


// --- CODE ---

/// I represent the home page.
class HomePage extends StatefulWidget {

  // constructor
  const HomePage({super.key});


  /// I create the mutable state for this widget.
  ///
  /// :returns: the state object for this widget.
  @override
  State<HomePage> createState() => _HomePageState();
}


/// I represent the mutable state for the home page.
class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {

  // state variables
  bool _btnPressed = false;

  // entrance animation
  late final AnimationController _entranceCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;


  /// I build the home page widget tree.
  ///
  /// :param context: the build context
  ///
  /// :returns: the home page widget tree
  @override
  Widget build(BuildContext context) {
    final screenW  = MediaQuery.of(context).size.width;
    final hPad     = screenW * 0.06;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // background image — takes all space above the bottom section
            Expanded(
              child: Image.asset(
                'assets/images/home_background.png',
                fit: BoxFit.cover,
              ),
            ),

            // bottom section — safe-area-aware so nav bar never hides content
            SlideTransition(
              position: _slideAnim,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // --- welcome text ---
                      Text(
                        'Bem-vindo ao Mescla Invest',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize:   36,
                          height:     44 / 36,
                          color:      Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- subtitle ---
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Acesse sua conta ou cadastre-se',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize:   21,
                            height:     25 / 21,
                            color:      _kBottom,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- login button ---
                      GestureDetector(
                        onTapDown:  (_) => setState(() => _btnPressed = true),
                        onTapUp:    (_) {
                          setState(() => _btnPressed = false);
                          context.go('/login');
                        },
                        onTapCancel: () => setState(() => _btnPressed = false),
                        child: AnimatedScale(
                          scale:    _btnPressed ? 0.97 : 1.0,
                          duration: const Duration(milliseconds: 80),
                          child: Container(
                            width:  double.infinity,
                            height: 58,
                            decoration: BoxDecoration(
                              color:        Colors.white,
                              border:       Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color:      Color(0x40000000),
                                  blurRadius: 4,
                                  offset:     Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'ENTRAR',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w300,
                                fontSize:   20,
                                height:     24 / 20,
                                color:      Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- register row ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Não possui conta?',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w400,
                              fontSize:   15,
                              height:     18 / 15,
                              color:      _kBottom,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => context.go('/register'),
                            child: Text(
                              'Cadastrar',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize:   20,
                                height:     24 / 20,
                                color:      _kBottom,
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// I clean up the animation controller when the widget is disposed.
  ///
  /// :returns: void
  @override
  void dispose() {
    _entranceCtrl.dispose();
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

    // define slide animation (bottom section slides up)
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));

    // start entrance animation
    _entranceCtrl.forward();
  }
}
