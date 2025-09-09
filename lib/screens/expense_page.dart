import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../models/expense.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String category = 'Others';
  bool loading = false;

  final List<String> categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Others'
  ];

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<SupabaseService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                    labelText: 'Title', prefixIcon: Icon(Icons.title)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                    labelText: 'Amount', prefixIcon: Icon(Icons.money)),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                items: categories
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => category = v ?? 'Others'),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 20),
              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        final title = titleController.text.trim();
                        final amount = double.tryParse(
                                amountController.text.trim()) ??
                            0;

                        if (title.isEmpty || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please provide valid title & amount')));
                          return;
                        }

                        setState(() => loading = true);
                        try {
                          await service.addExpense(Expense(
                              title: title,
                              amount: amount,
                              category: category,
                              date: DateTime.now()));
                          setState(() => loading = false);
                          Navigator.pop(context, true);
                        } catch (e) {
                          setState(() => loading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')));
                        }
                      },
                      child: const Text('Add Expense'),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
