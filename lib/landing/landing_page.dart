import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_sharemedia/auth/login/login.dart';
import 'package:new_sharemedia/auth/register/register.dart';

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            height: size.height,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: size.height * 0.25,
                        width: size.height * 0.25,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Wavora',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Ubuntu-Regular',
                        ),
                      ),
                      SizedBox(height: 12.0),
                      // Text(
                      //   'by NoCorps',
                      //   textAlign: TextAlign.center,
                      //   style: TextStyle(
                      //     fontSize: 16.0,
                      //     color: Colors.grey[600],
                      //     fontFamily: 'Ubuntu-Regular',
                      //     letterSpacing: 1.2,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: size.height * 0.05,
                  child: Text(
                    '© 2025 NoCorps',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: _buildButton('LOGIN', onTap: () => Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (_) => Login()),
            ))),
            SizedBox(width: 20),
            Expanded(child: _buildButton('SIGN UP', onTap: () => Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (_) => Register()),
            ))),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, {required VoidCallback onTap}) {
    return Expanded(
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(40.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40.0),
          child: Container(
            height: 45.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40.0),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Theme.of(context).colorScheme.secondary,
                  Color(0xff597FDB),
                ],
              ),
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
