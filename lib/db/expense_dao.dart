import 'package:tailormate/db/database_helper.dart';
import 'package:tailormate/models/expense.dart';

class ExpenseDAO {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Add a new expense
  Future<int> insertExpense(Expense expense) async {
    final db = await _dbHelper.database;
    return await db.insert('expenses', expense.toMap());
  }

  // Get all expenses for an order
  Future<List<Expense>> getExpensesForOrder(int orderId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'expenses',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  // Get total cost of all expenses for an order
  Future<double> getTotalForOrder(int orderId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE order_id = ?',
      [orderId],
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  // Update an expense
  Future<int> updateExpense(Expense expense) async {
    final db = await _dbHelper.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // Delete a single expense
  Future<int> deleteExpense(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all expenses for an order
  // (called when an order is deleted)
  Future<int> deleteExpensesForOrder(int orderId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'expenses',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }
}