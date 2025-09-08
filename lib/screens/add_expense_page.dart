import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../models/expense.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String selectedCategory = 'Food';
  DateTime selectedDate = DateTime.now();
  bool loading = false;

  Future<void> addExpense() async {
    if (titleController.text.isEmpty || amountController.text.isEmpty) return;

    setState(() => loading = true);

    try {
      final service = Provider.of<SupabaseService>(context, listen: false);

      final expense = Expense(
        title: titleController.text,
        amount: double.parse(amountController.text),
        category: selectedCategory,
        date: selectedDate,
      );

      await service.addExpense(expense);
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding expense: $e')),
      );
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        backgroundColor: const Color(0xFF6C63FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Title
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 20),

              // Amount
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 20),

              // Category
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: ['Food', 'Transport', 'Entertainment', 'Others']
                    .map<DropdownMenuItem<String>>(
                        (e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                    .toList(),
                onChanged: (String? value) {
                  if (value != null) setState(() => selectedCategory = value);
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 20),

              // Date Picker
              Row(
                children: [
                  Expanded(
                    child: Text(
                        'Date: ${selectedDate.year}-${selectedDate.month}-${selectedDate.day}'),
                  ),
                  ElevatedButton(
                    onPressed: pickDate,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF)),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Add Button
              ElevatedButton(
                onPressed: loading ? null : addExpense,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    minimumSize: const Size.fromHeight(50)),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Add Expense', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
