import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/supabase_service.dart';
import 'profile_page.dart';
import 'expense_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> expenses = [];
  List<Map<String, dynamic>> filtered = [];
  bool loading = true;

  Future<void> loadExpenses() async {
    setState(() => loading = true);
    final service = Provider.of<SupabaseService>(context, listen: false);
    final data = await service.fetchExpenses();
    setState(() {
      expenses = data.map((e) => e.toMap()).toList();
      filtered = expenses;
      loading = false;
    });
  }

  void _filter(String query) {
    setState(() {
      filtered = expenses.where((e) {
        final t = (e['title'] ?? '').toString().toLowerCase();
        final c = (e['category'] ?? '').toString().toLowerCase();
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
    final categoryTotals = <String, double>{};
    for (var e in expenses) {
      final amt = e['amount'];
      double v = 0;
      if (amt is num) {
        v = amt.toDouble();
      } else if (amt is String) v = double.tryParse(amt) ?? 0;
      total += v;
      final cat = (e['category'] ?? 'Others').toString();
      categoryTotals[cat] = (categoryTotals[cat] ?? 0) + v;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('TrackSy',
        style: TextStyle(color: Colors.white,fontSize: 20),),
        backgroundColor: tealDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
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
              context, MaterialPageRoute(builder: (_) => const ExpensePage()));
          if (didAdd == true) await loadExpenses();
        },
        backgroundColor: tealDark,
        child: const Icon(Icons.add),
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

                    // Pie chart for categories
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
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text('No expenses yet',
                                  style:
                                      TextStyle(color: Colors.grey.shade700)))
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, idx) {
                                final e = filtered[idx];
                                final title = e['title'] ?? 'Untitled';
                                final amt = e['amount'] ?? 0;
                                final cat = e['category'] ?? '';
                                final rawDate = e['date'] ?? '';
                                String dateStr = '';
                                try {
                                  dateStr = DateTime.parse(rawDate)
                                      .toLocal()
                                      .toString()
                                      .split('.')[0];
                                } catch (_) {
                                  dateStr = rawDate.toString();
                                }

                                return Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ListTile(
                                    title: Text(title),
                                    subtitle: Text('$cat • $dateStr'),
                                    trailing: Text(
                                        '\$${double.tryParse(amt.toString())?.toStringAsFixed(2) ?? amt.toString()}'),
                                    onLongPress: () async {
                                      final service = Provider.of<SupabaseService>(
                                          context,
                                          listen: false);
                                      await service.deleteExpense(e['id']);
                                      await loadExpenses();
                                    },
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
