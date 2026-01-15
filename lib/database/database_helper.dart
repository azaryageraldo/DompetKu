import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart' as models;
import '../models/transaction.dart' as models;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('keuangan_linci.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        type TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    // Insert default income categories
    await db.insert('categories', {
      'name': 'Kiriman dari Om',
      'type': 'income',
      'icon': 'card_giftcard',
      'color': '4CAF50',
    });
    await db.insert('categories', {
      'name': 'Gaji',
      'type': 'income',
      'icon': 'account_balance_wallet',
      'color': '2196F3',
    });
    await db.insert('categories', {
      'name': 'Bonus',
      'type': 'income',
      'icon': 'star',
      'color': 'FFC107',
    });
    await db.insert('categories', {
      'name': 'Hadiah',
      'type': 'income',
      'icon': 'redeem',
      'color': 'E91E63',
    });

    // Insert default expense categories
    await db.insert('categories', {
      'name': 'Makan',
      'type': 'expense',
      'icon': 'restaurant',
      'color': 'FF5722',
    });
    await db.insert('categories', {
      'name': 'Minum',
      'type': 'expense',
      'icon': 'local_cafe',
      'color': '795548',
    });
    await db.insert('categories', {
      'name': 'Transport',
      'type': 'expense',
      'icon': 'directions_car',
      'color': '9C27B0',
    });
    await db.insert('categories', {
      'name': 'Pulsa / Internet',
      'type': 'expense',
      'icon': 'phone_android',
      'color': '00BCD4',
    });
    await db.insert('categories', {
      'name': 'Hiburan',
      'type': 'expense',
      'icon': 'movie',
      'color': 'FF9800',
    });
  }

  // ========== CATEGORY CRUD OPERATIONS ==========

  Future<int> insertCategory(models.Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<models.Category>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => models.Category.fromMap(maps[i]));
  }

  Future<List<models.Category>> getCategoriesByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );
    return List.generate(maps.length, (i) => models.Category.fromMap(maps[i]));
  }

  Future<models.Category?> getCategoryById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return models.Category.fromMap(maps.first);
  }

  Future<int> updateCategory(models.Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== TRANSACTION CRUD OPERATIONS ==========

  Future<int> insertTransaction(models.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<models.Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    return List.generate(
        maps.length, (i) => models.Transaction.fromMap(maps[i]));
  }

  Future<List<models.Transaction>> getTransactionsByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
    return List.generate(
        maps.length, (i) => models.Transaction.fromMap(maps[i]));
  }

  Future<List<models.Transaction>> getTransactionsByDateRange(
      DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return List.generate(
        maps.length, (i) => models.Transaction.fromMap(maps[i]));
  }

  Future<models.Transaction?> getTransactionById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return models.Transaction.fromMap(maps.first);
  }

  Future<int> updateTransaction(models.Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== STATISTICS & REPORTS ==========

  Future<double> getTotalBalance() async {
    final db = await database;

    // Get total income
    final incomeResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      ['income'],
    );
    final totalIncome = incomeResult.first['total'] as double? ?? 0.0;

    // Get total expense
    final expenseResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      ['expense'],
    );
    final totalExpense = expenseResult.first['total'] as double? ?? 0.0;

    return totalIncome - totalExpense;
  }

  Future<double> getMonthlyIncome(int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ? AND date >= ? AND date <= ?',
      ['income', startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getMonthlyExpense(int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ? AND date >= ? AND date <= ?',
      ['expense', startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return result.first['total'] as double? ?? 0.0;
  }

  Future<Map<String, double>> getCategoryStats(
      String type, int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery('''
      SELECT c.name, SUM(t.amount) as total
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE t.type = ? AND t.date >= ? AND t.date <= ?
      GROUP BY c.name
      ORDER BY total DESC
    ''', [type, startDate.toIso8601String(), endDate.toIso8601String()]);

    Map<String, double> stats = {};
    for (var row in result) {
      stats[row['name'] as String] = row['total'] as double;
    }
    return stats;
  }

  Future<Map<String, dynamic>?> getTopCategory(
      String type, int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery('''
      SELECT c.name, c.icon, c.color, SUM(t.amount) as total
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE t.type = ? AND t.date >= ? AND t.date <= ?
      GROUP BY c.id
      ORDER BY total DESC
      LIMIT 1
    ''', [type, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isEmpty) return null;
    return result.first;
  }

  // Check if category has transactions
  Future<bool> categoryHasTransactions(int categoryId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions WHERE category_id = ?',
      [categoryId],
    );
    final count = result.first['count'] as int;
    return count > 0;
  }

  // Reset all data
  Future<void> resetAllData() async {
    final db = await database;
    // Delete all transactions and categories
    await db.delete('transactions');
    await db.delete('categories');

    // Re-insert default categories only (tables already exist)
    await _insertDefaultCategories(db);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
