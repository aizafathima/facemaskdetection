import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            '#STAY_SAFE',
            textStyle: GoogleFonts.getFont(
              'Roboto',
              fontSize: 25.0,
              fontWeight: FontWeight.w600,
              color: Color(0XFF565B64),
            ),
            speed: Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
