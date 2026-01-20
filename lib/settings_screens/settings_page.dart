import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/auth/loginCostumer.dart';
import 'package:projek_uts_mbr/databases/customerDatabase.dart';
import 'package:projek_uts_mbr/helper/semantics.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';
import 'package:provider/provider.dart';
import 'language_modal.dart';
import 'about_app_modal.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  final bool isTestMode;
  const SettingsPage({Key? key, this.isTestMode = false}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false;
  String _selectedLanguage = 'Indonesia';

  final TextEditingController _passwordController = TextEditingController();
  bool _isDeleting = false;
  bool _showPassword = false;
  late CustomerDatabase _customerDb; // Hapus final, jadikan late
  late SessionManager _sessionManager; // Tambah SessionManager

  @override
  void initState() {
    super.initState();
    // Inisialisasi dependencies di initState
    if (!widget.isTestMode) {
      _customerDb = CustomerDatabase();
      _sessionManager = SessionManager();
      _loadNotificationStatus();
    }
    // Untuk test mode, biarkan null - perlu handling di method yang menggunakan mereka
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    // Gunakan _sessionManager yang sudah diinisialisasi
    if (!widget.isTestMode) {
      await _sessionManager.logout();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginCustomer()),
      (route) => false,
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    final l10n = AppLocalizations.of(context)!;

    _passwordController.clear();
    _isDeleting = false;
    _showPassword = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
                const SizedBox(width: 10),
                Text(
                  l10n.deleteAccount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.deleteAccountWarning,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.deleteAccountConsequences,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.enterPasswordToConfirm,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    hintText: l10n.enterYourPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                  ),
                ),
                if (_isDeleting) ...[
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.deletingAccount,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: _isDeleting
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                child: Text(
                  l10n.cancel,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: _isDeleting
                    ? null
                    : () async {
                        if (_passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.pleaseEnterPassword),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _isDeleting = true;
                        });

                        await _deleteAccountWithPassword(
                          _passwordController.text,
                          setState,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  disabledBackgroundColor: Colors.red.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  l10n.deleteAccount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteAccountWithPassword(
    String password,
    StateSetter setState,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    // Handle test mode
    if (widget.isTestMode) {
      // Simulasi untuk test mode
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.of(context).pop();
      _showSuccessMessageAndLogout();
      return;
    }

    try {
      await _customerDb.reauthenticateUser(password);
      final success = await _customerDb.deleteCustomerAccount();

      if (success) {
        Navigator.of(context).pop();
        _showSuccessMessageAndLogout();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isDeleting = false;
      });

      String errorMessage = l10n.deleteAccountFailed;
      if (e.code == 'wrong-password') {
        errorMessage = l10n.wrongPassword;
      } else if (e.code == 'requires-recent-login') {
        errorMessage = l10n.requiresRecentLogin;
      } else if (e.code == 'too-many-requests') {
        errorMessage = l10n.tooManyAttempts;
      } else if (e.code == 'user-not-found') {
        errorMessage = "User tidak ditemukan";
      } else if (e.code == 'invalid-credential') {
        errorMessage = "Kredensial tidak valid";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.deleteAccountFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessMessageAndLogout() {
    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.accountDeletedSuccessfully),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      _logout();
    });
  }

  Future<void> _loadNotificationStatus() async {
    if (widget.isTestMode) {
      setState(() {
        _notificationsEnabled = false;
      });
      return;
    }

    final status = await _sessionManager.getNotificationStatus();
    setState(() {
      _notificationsEnabled = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final locale = languageProvider.locale;
    _selectedLanguage = languageProvider.getLanguageName();
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(
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
              _buildProfileSection(context),
              const SizedBox(height: 24),

              _buildSettingsSection(
                languageProvider,
                _selectedLanguage,
                context,
              ),

              const SizedBox(height: 32),
              _buildAboutSection(context),

              const SizedBox(height: 32),
              _buildDangerZoneSection(context),

              const SizedBox(height: 40),
              Semantics(
                label: tr('button', 'logoutButtonLabel', locale),
                hint: tr('button', 'logoutButtonHint', locale),
                excludeSemantics: true,
                child: _buildLogoutButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                Text(
                  l10n.appSettings,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.customizeYourExperience,
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

  Widget _buildSettingsSection(
    LanguageProvider languageProvider,
    String selectedLanguage,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final locale = languageProvider.locale;
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
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
            child: Row(
              children: [
                Icon(Icons.tune_rounded, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.mainSettings,
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

          Semantics(
            label: tr(
              'button',
              'settingsLanguageLabel',
              languageProvider.locale,
              params: {"name": _selectedLanguage},
            ),
            hint: tr(
              'button',
              'settingsLanguageHint',
              languageProvider.locale,
              params: {"name": _selectedLanguage},
            ),
            excludeSemantics: true,
            child: _buildSettingItem(
              icon: Icons.language_rounded,
              iconColor: Colors.blue,
              title: l10n.language,
              subtitle: _selectedLanguage,
              onTap: () async {
                final result = await showModalBottomSheet<String?>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) =>
                      LanguageModal(currentLanguage: selectedLanguage),
                );
                if (result != null) {
                  final newLocale = languageProvider.getLocaleFromName(result);
                  await languageProvider.setLocale(newLocale);

                  setState(() {
                    _selectedLanguage = result;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.languageChangedTo(result)),
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
          ),

          const Divider(indent: 20, endIndent: 20, height: 0),

          Semantics(
            label: tr('button', 'notifikasiButtonLabel', locale),
            hint: _notificationsEnabled
                ? tr('button', 'notifikasiButtonTHint', locale)
                : tr('button', 'notifikasiButtonFHint', locale),
            excludeSemantics: true,
            child: _buildNotificationSetting(context),
          ),

          const Divider(indent: 20, endIndent: 20, height: 0),

          Semantics(
            label: tr('button', 'themeButtonLabel', locale),
            hint: tr('button', 'themeButtonHint', locale),
            excludeSemantics: true,
            child: _buildSettingItem(
              icon: Icons.dark_mode_rounded,
              iconColor: Colors.purple,
              title: l10n.theme,
              subtitle: l10n.automatic,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSetting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
      title: Text(
        l10n.notifications,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        _notificationsEnabled ? l10n.enabled : l10n.disabled,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: Switch(
        value: _notificationsEnabled,
        onChanged: (value) async {
          final l10n = AppLocalizations.of(context)!;

          // Handle test mode
          if (widget.isTestMode) {
            setState(() {
              _notificationsEnabled = value;
            });
            return;
          }

          if (value) {
            print("notif user di set true");
            final isAllowed = await AwesomeNotifications()
                .isNotificationAllowed();
            if (!isAllowed) {
              final allow = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.notifPermissionTitle),
                  content: Text(l10n.notifPermissionDesc),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.notifPermissionCancel),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n.notifPermissionAllow),
                    ),
                  ],
                ),
              );

              if (allow == true) {
                await AwesomeNotifications()
                    .requestPermissionToSendNotifications();
              } else {
                return;
              }
            }
            await _sessionManager.setNotificationEnabled(true);
          } else {
            print("switch ke false");
            await AwesomeNotifications().cancelAllSchedules();
            await AwesomeNotifications().cancelAll();
            await _sessionManager.setNotificationEnabled(false);
          }

          setState(() {
            _notificationsEnabled = value;
          });
        },
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

  Widget _buildAboutSection(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final locale = languageProvider.locale;
    final l10n = AppLocalizations.of(context)!;
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
                Text(
                  l10n.aboutApp,
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

          Semantics(
            label: tr('button', 'aboutButtonLabel', locale),
            hint: tr('button', 'aboutButtonHint', locale),
            excludeSemantics: true,
            child: _buildAboutItem(
              icon: Icons.info_rounded,
              iconColor: Colors.blue,
              title: l10n.aboutApp,
              subtitle: l10n.appInformation("Ba Fang Lai Cai"),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => const AboutAppModal(),
                );
              },
            ),
          ),

          const Divider(indent: 20, endIndent: 20, height: 0),

          Semantics(
            label: tr('button', 'versionButtonLabel', locale),
            hint: tr('button', 'versionButtonHint', locale),
            excludeSemantics: true,
            child: Padding(
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
                title: Text(
                  l10n.appVersion,
                  style: const TextStyle(
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
                  child: Text(
                    l10n.latest,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const Divider(indent: 20, endIndent: 20, height: 0),

          Semantics(
            label: tr('button', 'termsButtonLabel', locale),
            hint: tr('button', 'termsButtonHint', locale),
            excludeSemantics: true,
            child: _buildAboutItem(
              icon: Icons.shield_rounded,
              iconColor: Colors.purple,
              title: l10n.termsPrivacy,
              subtitle: l10n.readOurPolicies,
              onTap: () {
                // Navigasi ke halaman terms
              },
            ),
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

  Widget _buildDangerZoneSection(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final locale = languageProvider.locale;
    final l10n = AppLocalizations.of(context)!;
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
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
            child: Row(
              children: [
                Icon(Icons.dangerous_rounded, color: Colors.red[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.dangerZone,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.red[700],
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Semantics(
            label: tr('button', 'deleteAccountButtonLabel', locale),
            hint: tr('button', 'deleteAccountButtonHint', locale),
            excludeSemantics: true,
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 16, right: 20),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red[700],
                  size: 22,
                ),
              ),
              title: Text(
                l10n.deleteAccount,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.red[700],
                ),
              ),
              subtitle: Text(
                l10n.permanentDeleteWarning,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              trailing: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                _showDeleteAccountDialog();
              },
            ),
          ),
        ],
      ),
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
