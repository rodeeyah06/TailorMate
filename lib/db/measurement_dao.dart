import 'package:tailormate/db/database_helper.dart';
import 'package:tailormate/models/measurement.dart';

class MeasurementDAO {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Save a new measurement
  Future<int> insertMeasurement(Measurement measurement) async {
    final db = await _dbHelper.database;
    return await db.insert('measurements', measurement.toMap());
  }

  // Get all measurements for a specific client (history)
  Future<List<Measurement>> getMeasurementsForClient(int clientId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'measurements',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'recorded_at DESC',
    );
    return result.map((map) => Measurement.fromMap(map)).toList();
  }

  // Get only the latest measurement for a client
  Future<Measurement?> getLatestMeasurement(int clientId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'measurements',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'recorded_at DESC',
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Measurement.fromMap(result.first);
  }

  // Update a measurement
  Future<int> updateMeasurement(Measurement measurement) async {
    final db = await _dbHelper.database;
    return await db.update(
      'measurements',
      measurement.toMap(),
      where: 'id = ?',
      whereArgs: [measurement.id],
    );
  }

  // Delete all measurements for a client
  // (called when a client is deleted)
  Future<int> deleteMeasurementsForClient(int clientId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'measurements',
      where: 'client_id = ?',
      whereArgs: [clientId],
    );
  }
}