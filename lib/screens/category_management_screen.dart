import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../widgets/category_icon.dart';
import '../widgets/custom/custom_loading.dart';
import '../widgets/custom/custom_notification.dart';
import '../widgets/custom/custom_dialog.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog(String type) {
    _showCategoryDialog(type: type);
  }

  void _showEditCategoryDialog(Category category) {
    _showCategoryDialog(type: category.type, category: category);
  }

  void _showCategoryDialog({required String type, Category? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    String selectedIcon = category?.icon ?? 'category';
    String selectedColor = category?.color ?? '2196F3';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(category == null
                  ? 'Tambah Kategori ${type == 'income' ? 'Pemasukan' : 'Pengeluaran'}'
                  : 'Edit Kategori ${type == 'income' ? 'Pemasukan' : 'Pengeluaran'}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Kategori',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedIcon,
                      decoration: const InputDecoration(
                        labelText: 'Icon',
                        border: OutlineInputBorder(),
                      ),
                      items: _getIconOptions().map((option) {
                        return DropdownMenuItem(
                          value: option['value'],
                          child: Row(
                            children: [
                              Icon(_getIconData(option['value']!)),
                              const SizedBox(width: 8),
                              Text(option['label']!),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedIcon = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedColor,
                      decoration: const InputDecoration(
                        labelText: 'Warna',
                        border: OutlineInputBorder(),
                      ),
                      items: _getColorOptions().map((option) {
                        return DropdownMenuItem(
                          value: option['value'],
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color(
                                      int.parse('0xFF${option['value']}')),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(option['label']!),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedColor = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      CustomNotification.show(
                        context,
                        message: 'Nama kategori tidak boleh kosong',
                        type: NotificationType.warning,
                      );
                      return;
                    }

                    final newCategory = Category(
                      id: category?.id,
                      name: nameController.text.trim(),
                      type: type,
                      icon: selectedIcon,
                      color: selectedColor,
                    );

                    try {
                      if (category == null) {
                        await Provider.of<CategoryProvider>(context,
                                listen: false)
                            .addCategory(newCategory);
                        if (context.mounted) {
                          Navigator.pop(context);
                          CustomNotification.show(
                            context,
                            message: 'Kategori berhasil ditambahkan',
                            type: NotificationType.success,
                          );
                        }
                      } else {
                        await Provider.of<CategoryProvider>(context,
                                listen: false)
                            .updateCategory(newCategory);
                        if (context.mounted) {
                          Navigator.pop(context);
                          CustomNotification.show(
                            context,
                            message: 'Kategori berhasil diperbarui',
                            type: NotificationType.success,
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        CustomNotification.show(
                          context,
                          message: 'Error: $e',
                          type: NotificationType.error,
                        );
                      }
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await CustomConfirmDialog.show(
      context,
      title: 'Hapus Kategori',
      message: 'Hapus kategori "${category.name}"?',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      icon: Icons.delete_outline,
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<CategoryProvider>(context, listen: false);
      final success = await provider.deleteCategory(category.id!);

      if (mounted) {
        if (success) {
          CustomNotification.show(
            context,
            message: 'Kategori berhasil dihapus',
            type: NotificationType.success,
          );
        } else {
          CustomNotification.show(
            context,
            message: 'Tidak dapat menghapus kategori yang memiliki transaksi',
            type: NotificationType.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Pemasukan'),
            Tab(text: 'Pengeluaran'),
          ],
        ),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const CustomLoadingIndicator();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryList(
                  provider.incomeCategories.cast<Category>(), 'income'),
              _buildCategoryList(
                  provider.expenseCategories.cast<Category>(), 'expense'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, String type) {
    final color =
        type == 'income' ? const Color(0xFF66BB6A) : const Color(0xFFEF5350);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () => _showAddCategoryDialog(type),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: 2,
              shadowColor: color.withAlpha(76),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_circle_outline, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Tambah Kategori ${type == 'income' ? 'Pemasukan' : 'Pengeluaran'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada kategori',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CategoryIcon(category: category),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            color: const Color(0xFF5B9BD5),
                            onPressed: () => _showEditCategoryDialog(category),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: const Color(0xFFEF5350),
                            onPressed: () => _deleteCategory(category),
                            tooltip: 'Hapus',
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<Map<String, String>> _getIconOptions() {
    return [
      {'label': 'Default', 'value': 'category'},
      {'label': 'Hadiah', 'value': 'card_giftcard'},
      {'label': 'Dompet', 'value': 'account_balance_wallet'},
      {'label': 'Bintang', 'value': 'star'},
      {'label': 'Kado', 'value': 'redeem'},
      {'label': 'Restoran', 'value': 'restaurant'},
      {'label': 'Kopi', 'value': 'local_cafe'},
      {'label': 'Mobil', 'value': 'directions_car'},
      {'label': 'HP', 'value': 'phone_android'},
      {'label': 'Film', 'value': 'movie'},
      {'label': 'Belanja', 'value': 'shopping_bag'},
      {'label': 'Rumah', 'value': 'home'},
      {'label': 'Sekolah', 'value': 'school'},
      {'label': 'Kesehatan', 'value': 'medical_services'},
      {'label': 'Olahraga', 'value': 'fitness_center'},
    ];
  }

  List<Map<String, String>> _getColorOptions() {
    return [
      {'label': 'Biru', 'value': '2196F3'},
      {'label': 'Hijau', 'value': '4CAF50'},
      {'label': 'Merah', 'value': 'F44336'},
      {'label': 'Orange', 'value': 'FF9800'},
      {'label': 'Ungu', 'value': '9C27B0'},
      {'label': 'Pink', 'value': 'E91E63'},
      {'label': 'Coklat', 'value': '795548'},
      {'label': 'Cyan', 'value': '00BCD4'},
      {'label': 'Kuning', 'value': 'FFC107'},
    ];
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'card_giftcard': Icons.card_giftcard,
      'account_balance_wallet': Icons.account_balance_wallet,
      'star': Icons.star,
      'redeem': Icons.redeem,
      'restaurant': Icons.restaurant,
      'local_cafe': Icons.local_cafe,
      'directions_car': Icons.directions_car,
      'phone_android': Icons.phone_android,
      'movie': Icons.movie,
      'shopping_bag': Icons.shopping_bag,
      'home': Icons.home,
      'school': Icons.school,
      'medical_services': Icons.medical_services,
      'fitness_center': Icons.fitness_center,
      'category': Icons.category,
    };
    return iconMap[iconName] ?? Icons.category;
  }
}
