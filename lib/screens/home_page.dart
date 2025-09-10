import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/supabase_service.dart';
import '../models/expense.dart';
import 'profile_page.dart';
import 'expense_page.dart';

//HomePage Widget 
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

//HomePage State 
class _HomePageState extends State<HomePage> {
  //Variables 
  List<Expense> expenses = [];
  List<Expense> filtered = [];
  bool loading = true;
  double monthlyBudget = 0; // Monthly budget variable

  //Load all expenses from Supabase 
  Future<void> loadExpenses() async {
    setState(() => loading = true);
    final service = Provider.of<SupabaseService>(context, listen: false);
    final data = await service.fetchExpenses();
    setState(() {
      expenses = data;
      filtered = expenses;
      loading = false;
    });
  }

  //Filter expenses by search query
  void _filter(String query) {
    setState(() {
      filtered = expenses.where((e) {
        final t = e.title.toLowerCase();
        final c = e.category.toLowerCase();
        return t.contains(query.toLowerCase()) ||
            c.contains(query.toLowerCase());
      }).toList();
    });
  }

  //Init State
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadExpenses());
  }

  //Helper getters for summaries 
  double get todaySpent {
    final now = DateTime.now();
    return expenses
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get weekSpent {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return expenses
        .where((e) => e.date.isAfter(weekAgo))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get monthSpent {
    final now = DateTime.now();
    return expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  //Show Expense Summary Dialog 
  void showExpenseSummary() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Expense Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today: ৳${todaySpent.toStringAsFixed(2)}'),
              Text('This Week: ৳${weekSpent.toStringAsFixed(2)}'),
              Text('This Month: ৳${monthSpent.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            )
          ],
        );
      },
    );
  }

  //Build UI 
  @override
  Widget build(BuildContext context) {
    final tealDark = Colors.teal.shade700;

    //Calculate total spent & category totals 
    double totalSpent = 0;
    final Map<String, double> categoryTotals = {};
    for (var e in expenses) {
      totalSpent += e.amount;
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }

    return Scaffold(
      //AppBar 
      appBar: AppBar(
        title: const Text(
          'TrackSy',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: tealDark,
        actions: [
          //Expense Summary Button
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: showExpenseSummary,
          ),
          //Profile Page Button 
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProfilePage()));
              await loadExpenses();
            },
          ),
        ],
      ),

      //Floating Action Button (Add Expense) 
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final didAdd = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ExpensePage()));
          if (didAdd == true) await loadExpenses();
        },
        backgroundColor: tealDark,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      //Body
      body: RefreshIndicator(
        onRefresh: loadExpenses,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Monthly Budget Card 
                    Card(
                      color: Colors.orange.shade50,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Monthly Budget',
                                          style: TextStyle(fontSize: 14)),
                                      const SizedBox(height: 6),
                                      Text('৳${monthlyBudget.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange.shade900)),
                                    ]),
                                //Edit Monthly Budget Button 
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (ctx) {
                                          final controller = TextEditingController(
                                              text: monthlyBudget.toStringAsFixed(2));
                                          return AlertDialog(
                                            title: const Text('Set Monthly Budget'),
                                            content: TextField(
                                              controller: controller,
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              decoration: const InputDecoration(
                                                  hintText: 'Enter budget in BDT'),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  final value = double.tryParse(controller.text.trim());
                                                  if (value != null && value > 0) {
                                                    setState(() {
                                                      monthlyBudget = value;
                                                    });
                                                  }
                                                  Navigator.pop(ctx);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.teal.shade700,
                                                ),
                                                child: const Text(
                                                  'Save',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          );
                                        });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            //Display Current Spent
                            Text(
                              'Current Spent: ৳${totalSpent.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: totalSpent > monthlyBudget
                                      ? Colors.red
                                      : Colors.green.shade700),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    //Pie chart for category totals
                    if (categoryTotals.isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: PieChart(PieChartData(
                          sections: categoryTotals.entries
                              .map((e) => PieChartSectionData(
                                  value: e.value,
                                  title: e.key,
                                  color: Colors
                                      .primaries[categoryTotals.keys.toList().indexOf(e.key) %
                                          Colors.primaries.length],
                                  radius: 60))
                              .toList(),
                        )),
                      ),
                    const SizedBox(height: 16),

                    //Search Field 
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search expense',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: _filter,
                    ),
                    const SizedBox(height: 12),

                    const Text('Recent Expenses',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),

                    //Expense List 
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text('No expenses yet',
                                  style: TextStyle(color: Colors.grey.shade700)))
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, idx) {
                                final e = filtered[idx];
                                return Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ListTile(
                                    title: Text(e.title),
                                    subtitle: Text(
                                        '${e.category} • ${e.date.toLocal().toString().split('.')[0]}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        //Edit Expense Button 
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.teal),
                                          onPressed: () async {
                                            final didUpdate = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        ExpensePage(expense: e)));
                                            if (didUpdate == true) await loadExpenses();
                                          },
                                        ),
                                        //Delete Expense Button 
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                                          onPressed: () async {
                                            final service = Provider.of<SupabaseService>(context,
                                                listen: false);
                                            if (e.id != null) {
                                              await service.deleteExpense(e.id!);
                                              await loadExpenses();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
