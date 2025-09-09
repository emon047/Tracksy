import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  // Sign up user
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    await client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'phone': phone}, // Use 'data' instead of 'userMetadata'
    );
  }

  // Sign in user
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out user
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return client.auth.currentUser;
  }

  // Add expense
  Future<void> addExpense(Expense expense) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    await client.from('expenses').insert({
      'user_id': userId,
      'title': expense.title,
      'amount': expense.amount,
      'category': expense.category,
      'date': expense.date.toIso8601String(),
    });
  }

  // Fetch expenses
  Future<List<Expense>> fetchExpenses() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await client
        .from('expenses')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);

    final rawList = response as List<dynamic>;
    return rawList.map((e) => Expense.fromMap(e)).toList();
  }

  // Delete expense
  Future<void> deleteExpense(String id) async {
    await client.from('expenses').delete().eq('id', id);
  }
}
