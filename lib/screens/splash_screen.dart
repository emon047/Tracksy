import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import 'login_page.dart';
import 'home_page.dart';

//SplashScreen Widget 
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

//SplashScreen State 
class _SplashScreenState extends State<SplashScreen> {
  //initState to handle navigation after delay 
  @override
  void initState() {
    super.initState();
    // Use post frame callback to safely access Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigate();
    });
  }

  //Navigate to Home or Login based on user login 
  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 5)); 

    final service = Provider.of<SupabaseService>(context, listen: false);
    final user = service.getCurrentUser();

    if (!mounted) return;

    if (user != null) {
      //Navigate to HomePage if user is logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      //Navigate to LoginPage if no user
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  //Build SplashScreen UI 
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Text(
          "TrackSy",
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
