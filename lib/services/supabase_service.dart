import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense.dart';

//SupabaseService: Wrapper around Supabase client 
class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;
  // Provides app-wide configured Supabase client

  //Sign Up User 
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    await client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'phone': phone}, // store extra fields in user metadata
    );
  }

  //Sign In User 
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  //Sign Out User 
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  //Get Current Logged-in User 
  User? getCurrentUser() {
    return client.auth.currentUser;
  }

  //Add New Expense 
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

  //Fetch Expenses for Current User 
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

  //Update Existing Expense 
  Future<void> updateExpense(Expense expense) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null || expense.id == null) {
      throw Exception('User not logged in or expense ID is null');
    }

    await client
        .from('expenses')
        .update({
          'title': expense.title,
          'amount': expense.amount,
          'category': expense.category,
          'date': expense.date.toIso8601String(),
        })
        .eq('id', expense.id!)
        .eq('user_id', userId);
  }

  //Delete Expense by ID 
  Future<void> deleteExpense(String id) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    await client
        .from('expenses')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}
