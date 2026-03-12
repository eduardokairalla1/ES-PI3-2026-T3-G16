// --- Home page ---
// Eduardo Kairalla - 24024241

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


// --- CODE ---

/// I represent the home page.
class HomePage extends StatelessWidget {

  // constructor
  const HomePage({super.key});


  /// I build the home page widget tree.
  /// 
  /// :param context: the build context
  /// 
  /// :returns: the home page widget tree
  @override
  Widget build(BuildContext context) {

    // get screen dimensions
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    // calculate scaling factors based on design dimensions (Figma prototype)
    final scaleX = screenW / 402;
    final scaleY = screenH / 793;

    // calculate content width and horizontal padding to center the content
    final contentWidth = screenW * 0.88;
    final contentPaddingH = (screenW - contentWidth) / 2;

    // return the home page scaffold
    return Scaffold(
      backgroundColor: Colors.white,

      body: SizedBox(
        width: screenW,
        height: screenH,
        child: Stack(
          children: [

            // background image
            Positioned(
              left: 0,
              top: 0,
              child: SizedBox(
                width: screenW,
                height: screenH * (508 / 793),
                child: Image.asset(
                  'assets/images/home_background.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // welcome text
            Positioned(
              left: contentPaddingH,
              top: screenH * (532 / 793),
              child: SizedBox(
                width: contentWidth,
                child: Text(
                  'Bem-vindo ao Mescla Invest',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 36 * scaleX,
                    height: 44 / 36,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // subtitle text
            Positioned(
              left: contentPaddingH,
              top: screenH * (630 / 793),
              child: SizedBox(
                width: contentWidth,
                child: Text(
                  'Acesse sua conta ou cadastre-se',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 21 * scaleX,
                    height: 25 / 21,
                    color: const Color(0xFF454545),
                  ),
                ),
              ),
            ),

            // login button
            Positioned(
              left: contentPaddingH,
              top: screenH * (671 / 793),
              child: Container(
                width: contentWidth,
                height: 58 * scaleY,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'ENTRAR',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 20 * scaleX,
                      height: 24 / 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),

            // register prompt
            Positioned(
              left: 0,
              top: screenH * (745 / 793),
              width: screenW,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Não possui conta?',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15 * scaleX,
                      height: 18 / 15,
                      color: const Color(0xFF454545),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.go('/register'),
                    child: Text(
                      'Cadastrar',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20 * scaleX,
                        height: 24 / 20,
                        color: const Color(0xFF454545),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
