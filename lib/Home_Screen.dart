import 'package:expensetrackerapp/Expense_Add_Screen.dart';
import 'package:expensetrackerapp/Expense_Model.dart';
import 'package:expensetrackerapp/Expense_See_all_Screen.dart';
import 'package:expensetrackerapp/Expense_Services.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double totalExpense = 0.0;
  List<Map<String, dynamic>> recentTransactions = [];
  List<Expense> allExpenses = [];
  List<Map<String, dynamic>> filteredTransactions = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadInitialTransactions();
  }

  Future<void> loadInitialTransactions() async {
    try {
      final List<Expense> expenses = await ExpenseServices().fetchExpenses();

      final summaryEntries =
          expenses.where((e) => e.category == 'Summary').toList();
      summaryEntries.sort(
        (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)),
      );

      final filtered =
          expenses
              .where((e) => e.title.isNotEmpty && e.category != 'Summary')
              .toList()
            ..sort(
              (a, b) =>
                  DateTime.parse(b.date).compareTo(DateTime.parse(a.date)),
            );

      double totalSpent = 0.0;
      for (final exp in filtered) {
        totalSpent += exp.amount;
      }

      final updatedTransactions = <Map<String, dynamic>>[
        ...filtered.map(
          (e) => {
            'title': e.title,
            'amount': e.amount,
            'date': DateTime.parse(e.date),
            'type': 'debit',
            'expense': e,
          },
        ),
      ];

      for (final entry in summaryEntries) {
        updatedTransactions.add({
          'title': entry.title,
          'amount': entry.amount,
          'date': DateTime.parse(entry.date),
          'type': 'credit',
          'expense': entry,
        });
      }

      updatedTransactions.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
      );

      setState(() {
        totalExpense = totalSpent;
        recentTransactions = updatedTransactions;
        filteredTransactions = updatedTransactions;
        allExpenses = filtered;
      });
    } catch (e) {
      print("Error loading balance/transactions: $e");
    }
  }

  void _filterTransactions(String query) {
    if (query.isEmpty) {
      setState(() => filteredTransactions = recentTransactions);
      return;
    }
    final lowerQuery = query.toLowerCase();
    final result =
        recentTransactions.where((tx) {
          final title = tx['title'].toString().toLowerCase();
          return title.contains(lowerQuery);
        }).toList();

    setState(() => filteredTransactions = result);
  }

  void _navigateToEditExpense(Expense expense) {
    if (expense.category == 'Summary') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Balance entries can't be edited or deleted."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseAddScreen(existingExpense: expense),
      ),
    ).then((_) => loadInitialTransactions());
  }

  void _showTransactionOptions(Expense expense) {
    if (expense.category == 'Summary') return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToEditExpense(expense);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () async {
                  Navigator.pop(context);
                  if (expense.id != null) {
                    await ExpenseServices().deleteExpenses(expense.id!);
                    await loadInitialTransactions();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Transaction deleted")),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Icon _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return const Icon(Icons.fastfood, color: Colors.deepOrange);
      case 'Shopping':
        return const Icon(Icons.shopping_bag, color: Colors.purple);
      case 'Travel':
        return const Icon(Icons.directions_car, color: Colors.teal);
      case 'Bills':
        return const Icon(Icons.receipt, color: Colors.indigo);
      default:
        return const Icon(Icons.category, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    String expenseDisplay = '₹ ${totalExpense.toStringAsFixed(2)}';
    final visibleTransactions = filteredTransactions.take(10).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ), 
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expense Tracker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.deepPurpleAccent),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: searchController,
              onChanged: _filterTransactions,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search transactions',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.deepPurpleAccent, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Expense',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  expenseDisplay,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => SeeAll_Expense_Screen(
                              transactions: recentTransactions,
                            ),
                      ),
                    );
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                visibleTransactions.isEmpty
                    ? const Center(child: Text('No transactions yet.'))
                    : ListView.builder(
                      itemCount: visibleTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = visibleTransactions[index];
                        final title = tx['title'];
                        final amount = tx['amount'];
                        final date = tx['date'] as DateTime;
                        final type = tx['type'];
                        final expense = tx['expense'] as Expense;

                        return ListTile(
                          onTap: () => _showTransactionOptions(expense),
                          leading: _getCategoryIcon(expense.category),
                          title: Text(title),
                          subtitle: Text(
                            '₹${amount.toStringAsFixed(2)} • ${date.day}/${date.month}/${date.year}',
                          ),
                          trailing: Text(
                            '₹${amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color:
                                  type == 'credit' ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExpenseAddScreen()),
          );
          await loadInitialTransactions();
        },
         backgroundColor: const Color.fromARGB(255, 84, 94, 247),
        child: const Icon(Icons.add,color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
