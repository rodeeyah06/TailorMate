import 'package:tailormate/db/database_helper.dart';
import 'package:tailormate/models/shopping_item.dart';

class ShoppingItemDAO {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Add a new shopping item
  Future<int> insertShoppingItem(ShoppingItem item) async {
    final db = await _dbHelper.database;
    return await db.insert('shopping_items', item.toMap());
  }

  // Get all shopping items for an order
  Future<List<ShoppingItem>> getShoppingItemsForOrder(int orderId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'shopping_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'is_bought ASC',
    );
    return result.map((map) => ShoppingItem.fromMap(map)).toList();
  }

  // Toggle item as bought or not bought
  Future<int> toggleBought(int id, bool isBought) async {
    final db = await _dbHelper.database;
    return await db.update(
      'shopping_items',
      {'is_bought': isBought ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update a shopping item
  Future<int> updateShoppingItem(ShoppingItem item) async {
    final db = await _dbHelper.database;
    return await db.update(
      'shopping_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Delete a single shopping item
  Future<int> deleteShoppingItem(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'shopping_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all shopping items for an order
  // (called when an order is deleted)
  Future<int> deleteShoppingItemsForOrder(int orderId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'shopping_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }
}