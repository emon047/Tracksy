import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<SupabaseService>(context, listen: false);
    final user = service.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: user == null
            ? const Center(child: Text('No user found'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${user.email}',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  Text('ID: ${user.id}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () async {
                        await service.signOut();
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent),
                      child: const Text('Sign Out'))
                ],
              ),
      ),
    );
  }
}
