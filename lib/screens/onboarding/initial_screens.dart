import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sanad/screens/onboarding/onboarding_screens.dart';
import 'package:sanad/screens/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ------------------------
/// INITIAL SCREEN (Onboarding or Splash)
/// ------------------------
class InitialScreen extends StatefulWidget {
  const InitialScreen({Key? key}) : super(key: key);
  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  bool _showOnboarding = true;
  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seen = prefs.getBool("onboardingSeen") ?? false;
    setState(() {
      _showOnboarding = !seen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showOnboarding ? OnboardingScreen() : const SplashScreen();
    // return _showOnboarding ? const OnboardingScreen() : const AdminDashboard();
  }
}
