import 'package:flutter/material.dart';
import 'package:tailormate/db/client_dao.dart';
import 'package:tailormate/models/client.dart';
import 'package:tailormate/models/measurement.dart';
import 'package:tailormate/models/order.dart';
import 'package:tailormate/db/expense_dao.dart';
import 'package:tailormate/db/shopping_dao.dart';
import 'package:tailormate/models/expense.dart';
import 'package:tailormate/models/shopping_item.dart';

import '../db/order_dao.dart';
import '../db/measurement_dao.dart';

class ClientProvider extends ChangeNotifier {
  final ClientDAO _clientDAO = ClientDAO();
  final MeasurementDAO _measurementDAO = MeasurementDAO();
  final OrderDAO _orderDAO = OrderDAO();
  final ExpenseDAO _expenseDAO = ExpenseDAO();
  final ShoppingItemDAO _shoppingItemDAO = ShoppingItemDAO();

  List<Client> _clients = [];
  List<Client> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = false;

  // Getters
  List<Client> get clients => _clients;
  List<Client> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  bool get isLoading => _isLoading;

  // Show either search results or all clients
  List<Client> get displayedClients =>
      _isSearching ? _searchResults : _clients;

  // ── CLIENT OPERATIONS ──

  Future<void> loadClients() async {
    _isLoading = true;
    notifyListeners();

    _clients = await _clientDAO.getAllClients();

    _isLoading = false;
    notifyListeners();
  }
  Future<Client?> getClientById(int id) async {
    return await _clientDAO.getClientById(id);
  }

  Future<void> addClient(Client client, Measurement measurement) async {
    final now = DateTime.now().toIso8601String();

    // Save client first
    final clientId = await _clientDAO.insertClient(
      client.copyWith(createdAt: now, updatedAt: now),
    );

    // Then save their measurements linked to that client
    await _measurementDAO.insertMeasurement(
      measurement.copyWith(
        clientId: clientId,
        recordedAt: now,
      ),
    );

    await loadClients();
  }

  Future<void> updateClient(Client client, Measurement measurement) async {
    final now = DateTime.now().toIso8601String();

    // Update client info
    await _clientDAO.updateClient(
      client.copyWith(updatedAt: now),
    );

    // Save new measurement as a new history entry
    await _measurementDAO.insertMeasurement(
      measurement.copyWith(
        clientId: client.id,
        recordedAt: now,
      ),
    );

    await loadClients();
  }

  Future<void> deleteClient(int clientId) async {
    // Delete client + all their data
    await _clientDAO.deleteClient(clientId);
    await _measurementDAO.deleteMeasurementsForClient(clientId);
    //await _orderDAO.deleteOrdersForClient(clientId);

    await loadClients();
  }

  // ── SEARCH ──

  Future<void> searchClients(String query) async {
    if (query.isEmpty) {
      _isSearching = false;
      _searchResults = [];
      notifyListeners();
      return;
    }
    _isSearching = true;
    _searchResults = await _clientDAO.searchClients(query);
    notifyListeners();
  }

  void clearSearch() {
    _isSearching = false;
    _searchResults = [];
    notifyListeners();
  }

  // ── MEASUREMENTS ──

  Future<Measurement?> getLatestMeasurement(int clientId) async {
    return await _measurementDAO.getLatestMeasurement(clientId);
  }

  Future<List<Measurement>> getMeasurementHistory(int clientId) async {
    return await _measurementDAO.getMeasurementsForClient(clientId);
  }

  // ── ORDERS ──

  Future<void> addOrder(TailorOrder order) async {
    await _orderDAO.insertOrder(order);
    notifyListeners();
  }

   Future<void> updateOrder(TailorOrder order) async {
    await _orderDAO.updateOrder(order);
    notifyListeners();
  }

  Future<void> deleteOrder(int orderId) async {
    await _orderDAO.deleteOrder(orderId);
    await _expenseDAO.deleteExpensesForOrder(orderId);        // 👈 add
    await _shoppingItemDAO.deleteShoppingItemsForOrder(orderId); // 👈 add
    notifyListeners();
  }

  Future<List<TailorOrder>> getOrdersForClient(int clientId) async {
    return await _orderDAO.getOrdersForClient(clientId);
  }

  Future<List<TailorOrder>> getAllOrders() async {
    return await _orderDAO.getAllOrders();
  }

  Future<List<TailorOrder>> getOrdersByStatus(String status) async {
    return await _orderDAO.getOrdersByStatus(status);
  }
  // ── EXPENSES ──

  Future<void> addExpense(Expense expense) async {
    await _expenseDAO.insertExpense(expense);
    notifyListeners();
  }

  Future<List<Expense>> getExpensesForOrder(int orderId) async {
    return await _expenseDAO.getExpensesForOrder(orderId);
  }

  Future<double> getTotalForOrder(int orderId) async {
    return await _expenseDAO.getTotalForOrder(orderId);
  }

  Future<void> deleteExpense(int expenseId) async {
    await _expenseDAO.deleteExpense(expenseId);
    notifyListeners();
  }

// ── SHOPPING LIST ──

  Future<void> addShoppingItem(ShoppingItem item) async {
    await _shoppingItemDAO.insertShoppingItem(item);
    notifyListeners();
  }

  Future<List<ShoppingItem>> getShoppingItemsForOrder(int orderId) async {
    return await _shoppingItemDAO.getShoppingItemsForOrder(orderId);
  }

  Future<void> toggleShoppingItem(int id, bool isBought) async {
    await _shoppingItemDAO.toggleBought(id, isBought);
    notifyListeners();
  }

  Future<void> deleteShoppingItem(int id) async {
    await _shoppingItemDAO.deleteShoppingItem(id);
    notifyListeners();
  }
}