// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  Future<dynamic> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final resp = await client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'phone': phone},
    );
    return resp;
  }

  Future<dynamic> signIn({
    required String email,
    required String password,
  }) async {
    final resp = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return resp;
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<bool> addExpense({
    required String title,
    required double amount,
    required String category,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;
    await client.from('expenses').insert({
      'user_id': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'date': DateTime.now().toIso8601String(),
    });
    return true;
  }

  Future<List<Map<String, dynamic>>> fetchExpenses() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];
    final response = await client
        .from('expenses')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);
    final raw = response as List<dynamic>;
    return raw.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<bool> deleteExpense(dynamic id) async {
    await client.from('expenses').delete().eq('id', id);
    return true;
  }

  User? getCurrentUser() => client.auth.currentUser;
}
