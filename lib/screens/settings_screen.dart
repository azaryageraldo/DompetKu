import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'category_management_screen.dart';
import 'profile_setup_screen.dart';
import '../widgets/custom/custom_notification.dart';
import '../widgets/custom/custom_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _resetData(BuildContext context) async {
    final confirmed = await CustomConfirmDialog.show(
      context,
      title: 'Konfirmasi Reset',
      message: 'Apakah Anda yakin ingin menghapus semua data? '
          'Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Reset',
      cancelText: 'Batal',
      confirmColor: const Color(0xFFEF5350),
      icon: Icons.warning_amber_outlined,
    );

    if (confirmed == true && context.mounted) {
      try {
        await DatabaseHelper.instance.resetAllData();
        if (context.mounted) {
          CustomNotification.show(
            context,
            message: 'Data berhasil direset',
            type: NotificationType.success,
          );
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Section
          Text(
            'Akun',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          _buildSettingItem(
            icon: Icons.person_outline_rounded,
            iconColor: const Color(0xFF5B9BD5),
            title: 'Atur Profil',
            subtitle: 'Ubah nama dan foto profil',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ProfileSetupScreen(isEditing: true),
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          // Category Management Section
          Text(
            'Kategori',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          _buildSettingItem(
            icon: Icons.category_outlined,
            iconColor: const Color(0xFF5B9BD5),
            title: 'Kelola Kategori',
            subtitle: 'Tambah, edit, atau hapus kategori',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryManagementScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          // Data Section
          Text(
            'Data',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          _buildSettingItem(
            icon: Icons.delete_forever_outlined,
            iconColor: const Color(0xFFEF5350),
            title: 'Reset Data',
            subtitle: 'Hapus semua transaksi dan kategori',
            onTap: () => _resetData(context),
          ),

          const SizedBox(height: 28),

          // About Section
          Text(
            'Tentang',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          _buildSettingItem(
            icon: Icons.info_outlined,
            iconColor: const Color(0xFF5B9BD5),
            title: 'Tentang Aplikasi',
            subtitle: 'DompetKu v1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'DompetKu',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 48,
                  color: Color(0xFF5B9BD5),
                ),
                children: const [
                  Text(
                    'Aplikasi Catatan Keuangan Pribadi\n\n'
                    'Kelola pemasukan dan pengeluaran Anda dengan mudah. '
                    'Semua data tersimpan lokal di perangkat Anda.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
