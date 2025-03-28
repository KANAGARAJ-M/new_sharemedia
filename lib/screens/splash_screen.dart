import 'package:flutter/material.dart';
import 'package:new_sharemedia/landing/landing_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLanding();
  }

  _navigateToLanding() async {
    await Future.delayed(Duration(seconds: 2));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Landing()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/shmnew_logo.png',
              height: 120.0,
              width: 120.0,
            ),
            SizedBox(height: 20),
            Text(
              'NoCorps',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Connect • Share • Inspire',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}