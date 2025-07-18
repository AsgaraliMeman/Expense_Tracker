import 'package:flutter/material.dart';
import 'package:expensetrackerapp/Expense_Model.dart';
import 'package:expensetrackerapp/Expense_Add_Screen.dart';

class SeeAll_Expense_Screen extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  const SeeAll_Expense_Screen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var tx in transactions) {
      String dateKey =
          "${tx['date'].day}-${tx['date'].month}-${tx['date'].year}";
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(tx);
    }

    List<String> sortedDates =
        grouped.keys.toList()..sort((a, b) {
          final d1 = DateTime.parse(
            "2023-${a.split('-')[1].padLeft(2, '0')}-${a.split('-')[0].padLeft(2, '0')}",
          );
          final d2 = DateTime.parse(
            "2023-${b.split('-')[1].padLeft(2, '0')}-${b.split('-')[0].padLeft(2, '0')}",
          );
          return d2.compareTo(d1);
        });

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Transactions"),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final txs = grouped[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                width: double.infinity,
                child: Text(
                  date,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...txs.map((tx) {
                final type = tx['type'];
                final expense = tx['expense'] as Expense;
                return ListTile(
                  onTap: () {
                    if (expense.category != 'Summary') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ExpenseAddScreen(existingExpense: expense),
                        ),
                      );
                    }
                  },
                  leading: Icon(
                    type == 'credit'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: type == 'credit' ? Colors.green : Colors.red,
                  ),
                  title: Text(expense.title),
                  subtitle: Text('₹${expense.amount.toStringAsFixed(2)}'),
                  trailing: Text(
                    '${type == 'credit' ? '+' : '-'}₹${expense.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: type == 'credit' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
