import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String _filterType = 'all'; // 'all', 'income', 'expense'

  List<Transaction> get transactions {
    if (_filterType == 'all') {
      return _transactions;
    } else {
      return _transactions.where((t) => t.type == _filterType).toList();
    }
  }

  bool get isLoading => _isLoading;
  String get filterType => _filterType;

  void setFilter(String type) {
    _filterType = type;
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions =
          (await _dbHelper.getAllTransactions()).cast<Transaction>();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      final id = await _dbHelper.insertTransaction(transaction);
      _transactions.insert(0, transaction.copyWith(id: id));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _dbHelper.updateTransaction(transaction);
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _dbHelper.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  Future<double> getTotalBalance() async {
    try {
      return await _dbHelper.getTotalBalance();
    } catch (e) {
      debugPrint('Error getting total balance: $e');
      return 0.0;
    }
  }

  Future<double> getMonthlyIncome(int year, int month) async {
    try {
      return await _dbHelper.getMonthlyIncome(year, month);
    } catch (e) {
      debugPrint('Error getting monthly income: $e');
      return 0.0;
    }
  }

  Future<double> getMonthlyExpense(int year, int month) async {
    try {
      return await _dbHelper.getMonthlyExpense(year, month);
    } catch (e) {
      debugPrint('Error getting monthly expense: $e');
      return 0.0;
    }
  }

  Future<Map<String, double>> getCategoryStats(
      String type, int year, int month) async {
    try {
      return await _dbHelper.getCategoryStats(type, year, month);
    } catch (e) {
      debugPrint('Error getting category stats: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>?> getTopCategory(
      String type, int year, int month) async {
    try {
      return await _dbHelper.getTopCategory(type, year, month);
    } catch (e) {
      debugPrint('Error getting top category: $e');
      return null;
    }
  }
}
