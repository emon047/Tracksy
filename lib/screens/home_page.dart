import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/supabase_service.dart';
import '../models/expense.dart';
import 'profile_page.dart';
import 'expense_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Expense> expenses = [];
  List<Expense> filtered = [];
  bool loading = true;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadExpenses());
  }

  @override
  Widget build(BuildContext context) {
    final tealDark = Colors.teal.shade700;

    double total = 0;
    final Map<String, double> categoryTotals = {};
    for (var e in expenses) {
      total += e.amount;
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TrackSy',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: tealDark,
        actions: [
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
      body: RefreshIndicator(
        onRefresh: loadExpenses,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Monthly Spend',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700)),
                                  const SizedBox(height: 6),
                                  Text('\$${total.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal.shade900)),
                                ]),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Items',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700)),
                                const SizedBox(height: 6),
                                Text('${expenses.length}',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal.shade900)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Pie chart
                    if (categoryTotals.isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: PieChart(PieChartData(
                          sections: categoryTotals.entries
                              .map((e) => PieChartSectionData(
                                  value: e.value,
                                  title: e.key,
                                  color: Colors
                                      .primaries[categoryTotals.keys
                                              .toList()
                                              .indexOf(e.key) %
                                          Colors.primaries.length],
                                  radius: 60))
                              .toList(),
                        )),
                      ),
                    const SizedBox(height: 16),

                    // Search
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

                    // Expense List
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text('No expenses yet',
                                  style: TextStyle(
                                      color: Colors.grey.shade700)))
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
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
                                        // Edit button
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.teal),
                                          onPressed: () async {
                                            final didUpdate =
                                                await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            ExpensePage(
                                                                expense: e)));
                                            if (didUpdate == true)
                                              await loadExpenses();
                                          },
                                        ),
                                        // Delete button
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.redAccent),
                                          onPressed: () async {
                                            final service = Provider.of<
                                                    SupabaseService>(context,
                                                listen: false);
                                            if (e.id != null) {
                                              await service
                                                  .deleteExpense(e.id!);
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
