import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:artfolio/firebase_auth/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  final Color backgroundColor;
  final Duration duration;

  SplashScreen({
    this.backgroundColor = Colors.white,
    this.duration = const Duration(seconds: 2),
  });

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    _controller.forward();

    Timer(widget.duration, () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => LoginPage(), // change for authentication screen log in
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _animation,
              child: AnimatedTextKit(
                animatedTexts: [
                  ScaleAnimatedText(
                    'Artfolio', 
                    textStyle: GoogleFonts.macondo(
                      textStyle: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
                totalRepeatCount: 3,
              ),
            ),
            SizedBox(height: 100),
            BuzzingImageAnimation(),
          ],
        ),
      ),
    );
  }
}

class BuzzingImageAnimation extends StatefulWidget {
  @override
  _BuzzingImageAnimationState createState() => _BuzzingImageAnimationState();
}

class _BuzzingImageAnimationState extends State<BuzzingImageAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0.0, _controller.value * 50),
          child: Image.asset(
            'assets/file.png',
            width: 150,
            height: 150,
          ),
        );
      },
    );
  }
}
