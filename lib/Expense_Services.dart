import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expensetrackerapp/Expense_Model.dart';

class ExpenseServices {
  final String baseUrl = "https://6878d19463f24f1fdc9f949a.mockapi.io/expenses";

  // Fetch Expenses
  Future<List<Expense>> fetchExpenses() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Expense.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load expenses");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Add Expense
  Future<void> addExpenses(Expense expense) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(expense.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception("Failed to add Expense");
    }
  }

  // Update Expense
  Future<void> updateExpenses(String id, Expense expense) async {
    final url = '$baseUrl/$id';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(expense.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update Expense");
    }
  }

  // Delete Expense
  Future<void> deleteExpenses(String id) async {
    final url = '$baseUrl/$id';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception("Failed to delete Expense");
    }
  }
}
