import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qewrjepktqnadmoyjgne.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFld3JqZXBrdHFuYWRtb3lqZ25lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTczNjAzODgsImV4cCI6MjA3MjkzNjM4OH0.NsHbaG160vHw79Q1NNVD7UA1r71acy9016cWK4AOSYo',
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<SupabaseService>(create: (_) => SupabaseService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const teal = Colors.teal;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TrackSy',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.teal.shade50,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: teal.shade700,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
