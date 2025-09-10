import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../models/expense.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key, this.expense});

  final Expense? expense; // For update functionality

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
  void initState() {
    super.initState();
    if (widget.expense != null) {
      titleController.text = widget.expense!.title;
      amountController.text = widget.expense!.amount.toString();
      category = widget.expense!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<SupabaseService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.expense == null ? 'Add Expense' : 'Update Expense',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
                          if (widget.expense == null) {
                            // Add new expense
                            await service.addExpense(Expense(
                                title: title,
                                amount: amount,
                                category: category,
                                date: DateTime.now()));
                          } else {
                            // Update existing expense
                            await service.updateExpense(Expense(
                                id: widget.expense!.id,
                                title: title,
                                amount: amount,
                                category: category,
                                date: widget.expense!.date));
                          }

                          setState(() => loading = false);
                          Navigator.pop(context, true);
                        } catch (e) {
                          setState(() => loading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')));
                        }
                      },
                      child: Text(
                        widget.expense == null ? 'Add Expense' : 'Update Expense',
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}