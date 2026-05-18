import 'package:tailormate/db/database_helper.dart';
import 'package:tailormate/models/order.dart';

class OrderDAO {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Save a new order
  Future<int> insertOrder(TailorOrder order) async {
    final db = await _dbHelper.database;
    return await db.insert('orders', order.toMap());
  }

  // Get all orders
  Future<List<TailorOrder>> getAllOrders() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'orders',
      orderBy: 'due_date ASC',
    );
    return result.map((map) => TailorOrder.fromMap(map)).toList();
  }

  // Get all orders for a specific client
  Future<List<TailorOrder>> getOrdersForClient(int clientId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'orders',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'due_date ASC',
    );
    return result.map((map) => TailorOrder.fromMap(map)).toList();
  }

  // Get orders by status (pending / in_progress / done)
  Future<List<TailorOrder>> getOrdersByStatus(String status) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'orders',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'due_date ASC',
    );
    return result.map((map) => TailorOrder.fromMap(map)).toList();
  }
  Future<int> updateOrder(TailorOrder order) async {
    final db = await _dbHelper.database;
    return await db.update(
      'orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<int> deleteOrder(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}