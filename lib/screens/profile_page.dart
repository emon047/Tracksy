// lib/screens/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as p;
import '../services/supabase_service.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = p.Provider.of<SupabaseService>(context, listen: false);
    final user = service.getCurrentUser();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), backgroundColor: Colors.teal.shade700),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 36, backgroundColor: Colors.teal.shade200, child: const Icon(Icons.person, size: 40, color: Colors.white)),
              const SizedBox(height: 14),
              Text(user?.email ?? 'No email', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('User ID: ${user?.id ?? 'Unknown'}', style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () async {
                  await service.signOut();
                  // navigate back to login and clear stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
