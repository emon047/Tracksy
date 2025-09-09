import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL', anonKey: 'YOUR_SUPABASE_ANON_KEY');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => SupabaseService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TrackSy',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
