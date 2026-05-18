import 'package:tailormate/db/database_helper.dart';
import 'package:tailormate/models/client.dart';

class ClientDAO {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Save a new client
  Future<int> insertClient(Client client) async {
    final db = await _dbHelper.database;
    return await db.insert('clients', client.toMap());
  }

  // Get all clients
  Future<List<Client>> getAllClients() async {
    final db = await _dbHelper.database;
    final result = await db.query('clients', orderBy: 'name ASC');
    return result.map((map) => Client.fromMap(map)).toList();
  }

  // Get one client by id
  Future<Client?> getClientById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Client.fromMap(result.first);
  }

  // Search clients by name
  Future<List<Client>> searchClients(String query) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'clients',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return result.map((map) => Client.fromMap(map)).toList();
  }

  // Update existing client
  Future<int> updateClient(Client client) async {
    final db = await _dbHelper.database;
    return await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }


  // Delete a client
  Future<int> deleteClient(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}