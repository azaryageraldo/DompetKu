import 'package:flutter/foundation.dart' hide Category;
import '../database/database_helper.dart';
import '../models/category.dart';

class CategoryProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  List<Category> get incomeCategories =>
      _categories.where((c) => c.type == 'income').toList();

  List<Category> get expenseCategories =>
      _categories.where((c) => c.type == 'expense').toList();

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _dbHelper.getAllCategories();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      final id = await _dbHelper.insertCategory(category);
      _categories.add(category.copyWith(id: id));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _dbHelper.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating category: $e');
      rethrow;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      // Check if category has transactions
      final hasTransactions = await _dbHelper.categoryHasTransactions(id);
      if (hasTransactions) {
        return false; // Cannot delete category with transactions
      }

      await _dbHelper.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      rethrow;
    }
  }

  Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
