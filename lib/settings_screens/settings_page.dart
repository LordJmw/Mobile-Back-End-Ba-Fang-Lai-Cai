import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/auth/loginCostumer.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';
import 'language_modal.dart';
import 'about_app_modal.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Indonesia';

  Future<void> _logout() async {
    final session = SessionManager();
    await session.logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginCustomer()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Profile Section
              _buildProfileSection(),
              const SizedBox(height: 24),

              // App Settings Section
              _buildSettingsSection(),

              // About Section
              const SizedBox(height: 32),
              _buildAboutSection(),

              // Logout Button
              const SizedBox(height: 40),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 250, 90, 143),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: ClipOval(
              child: Container(
                color: Colors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.settings_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pengaturan Aplikasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sesuaikan pengalaman aplikasi Anda',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section Title
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
            child: Row(
              children: [
                Icon(Icons.tune_rounded, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'PENGATURAN UTAMA',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.blueGrey,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Language Setting
          _buildSettingItem(
            icon: Icons.language_rounded,
            iconColor: Colors.blue,
            title: 'Bahasa',
            subtitle: _selectedLanguage,
            onTap: () async {
              final result = await showModalBottomSheet<String?>(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) =>
                    LanguageModal(currentLanguage: _selectedLanguage),
              );
              if (result != null) {
                setState(() {
                  _selectedLanguage = result;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bahasa diubah ke $result'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
          ),

          const Divider(indent: 20, endIndent: 20, height: 0),

          // Notifications Setting
          _buildNotificationSetting(),

          const Divider(indent: 20, endIndent: 20, height: 0),

          // Theme Setting (Optional)
          _buildSettingItem(
            icon: Icons.dark_mode_rounded,
            iconColor: Colors.purple,
            title: 'Tema',
            subtitle: 'Otomatis',
            onTap: () {
              // Untuk tema bisa ditambahkan nanti
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSetting() {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 20),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.notifications_active_rounded,
          color: Colors.orange[700],
          size: 22,
        ),
      ),
      title: const Text(
        'Notifikasi',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        _notificationsEnabled ? 'Diaktifkan' : 'Dinonaktifkan',
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: Switch(
        value: _notificationsEnabled,
        onChanged: (value) {
          setState(() {
            _notificationsEnabled = value;
          });
        },
        activeColor: Colors.pink[250],
        activeTrackColor: Colors.pink[100],
      ),
      onTap: () {
        setState(() {
          _notificationsEnabled = !_notificationsEnabled;
        });
      },
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 20),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: Colors.grey,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildAboutSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section Title
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Colors.green[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'TENTANG APLIKASI',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.blueGrey,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // About App
          _buildAboutItem(
            icon: Icons.info_rounded,
            iconColor: Colors.blue,
            title: 'Tentang Aplikasi',
            subtitle: 'Informasi tentang EventHub',
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => const AboutAppModal(),
              );
            },
          ),

          const Divider(indent: 20, endIndent: 20, height: 0),

          // App Version
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 16, right: 20),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_rounded,
                  color: Colors.green[700],
                  size: 22,
                ),
              ),
              title: const Text(
                'Versi Aplikasi',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              subtitle: const Text(
                '1.0.0',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Terbaru',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          const Divider(indent: 20, endIndent: 20, height: 0),

          // Terms & Privacy
          _buildAboutItem(
            icon: Icons.shield_rounded,
            iconColor: Colors.purple,
            title: 'Ketentuan & Privasi',
            subtitle: 'Baca kebijakan kami',
            onTap: () {
              // Navigasi ke halaman terms
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 20),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: Colors.grey,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          _logout();
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        child: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
