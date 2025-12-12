import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:projek_uts_mbr/analytics/eventLogs.dart';
import 'package:projek_uts_mbr/auth/loginCostumer.dart';
import 'package:projek_uts_mbr/databases/customerDatabase.dart';
import 'package:projek_uts_mbr/helper/semantics.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/model/CustomerModel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:provider/provider.dart';

class RegisterCustomer extends StatefulWidget {
  const RegisterCustomer({super.key});

  @override
  State<RegisterCustomer> createState() => _RegisterCustomerState();
}

class _RegisterCustomerState extends State<RegisterCustomer> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  Future<bool> _requestContactPermission(BuildContext context) async {
    PermissionStatus status = await Permission.contacts.status;
    final l10n = AppLocalizations.of(context)!;
    if (status.isGranted) return true;

    bool firstDialog = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: Text(l10n.permissionContactRequired),
          content: Text(l10n.permissionContactRequiredMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.continueDialog),
            ),
          ],
        );
      },
    );

    if (!firstDialog) return false;

    status = await Permission.contacts.request();

    if (status.isGranted) return true;

    if (status.isDenied) {
      bool secondDialog = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: Text(l10n.permissionRequired),
            content: Text(l10n.pleaseAllowContactToRegister),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.tryAgain),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
            ],
          );
        },
      );

      if (!secondDialog) return false;

      status = await Permission.contacts.request();

      if (status.isGranted) return true;

      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.contactPermissionDenied),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.contactPermissionBlocked),
          backgroundColor: Colors.red,
        ),
      );
      openAppSettings();
      return false;
    }

    return false;
  }

  Future<void> _saveCustomer(BuildContext context,lang) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      if (!_formKey.currentState!.validate()){
        SemanticsService.announce(
        tr('button', 'registerKosong', lang),
        TextDirection.ltr);
        return;
      } 

      bool granted = await _requestContactPermission(context);
      if (!granted) return;

      final customer = CustomerModel(
        nama: _namaController.text,
        email: _emailController.text,
        password: _passwordController.text,
        telepon: _teleponController.text,
        alamat: _alamatController.text,
        fotoProfil: null,
      );

      final db = CustomerDatabase();
      await db.insertCustomer(customer);

      final eventlogs = Eventlogs();
      await eventlogs.logRegisterActivity(
        customer.email,
        "customer",
        customer.alamat,
        customer.telepon,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(l10n.registerSuccess),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginCustomer()),
      );
    } catch (e) {
      if (e.toString().contains("EMAIL_USED")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(l10n.registerEmailUsed),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("${l10n.registerGeneralError(e)}"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    l10n.registerCreateTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.registerCreateSubtitle,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  Semantics(
                    label: tr('textField', 'namaLabel', lang),
                    hint: tr('textField', 'namaHint', lang),
                    excludeSemantics: true,
                    child: TextFormField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),
                        labelText: l10n.registerFullName,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? l10n.errorNameRequired : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Semantics(
                    label: tr('textField', 'emailLabel', lang),
                    hint: tr('textField', 'emailHint', lang),
                    excludeSemantics: true,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        labelText: l10n.registerEmail,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return l10n.errorEmailRequired;
                        final regex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!regex.hasMatch(value))
                          return l10n.errorEmailInvalid;
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Semantics(
                    label: tr('textField', 'passwordLabel', lang),
                    hint: tr('textField', 'passwordHint', lang),
                    excludeSemantics: true,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        labelText: l10n.registerPassword,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return l10n.errorPasswordRequired;
                        if (value.length < 6)
                          return l10n.errorPasswordMinLength;
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Semantics(
                    label: tr('textField', 'confirmPasswordLabel', lang),
                    hint: tr('textField', 'confirmPasswordHint', lang),
                    excludeSemantics: true,
                    child: TextFormField(
                      controller: _confirmController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        labelText: l10n.registerConfirmPassword,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty)
                          return l10n.errorConfirmPasswordRequired;
                        if (value != _passwordController.text)
                          return l10n.errorPasswordNotMatch;
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Semantics(
                    label: tr('textField', 'teleponLabel', lang),
                    hint: tr('textField', 'teleponHint', lang),
                    excludeSemantics: true,
                    child: TextFormField(
                      controller: _teleponController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone_android_outlined),
                        labelText: l10n.registerPhoneNumber,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return l10n.errorPhoneRequired;
                        final regex = RegExp(r'^[0-9]+$');
                        if (!regex.hasMatch(value))
                          return l10n.errorPhoneOnlyNumber;
                        if (value.length < 10) return l10n.errorPhoneMinDigit;
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Semantics(
                    label: tr('textField', 'alamatLabel', lang),
                    hint: tr('textField', 'alamatHint', lang),
                    excludeSemantics: true,
                    child: TextFormField(
                      controller: _alamatController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.home_outlined),
                        labelText: l10n.registerAddress,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? l10n.errorAddressRequired : null,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Semantics(
                    label: tr('button', 'registerAkunButtonLabel', lang),
                    hint: tr('button', 'registerAkunButtonHint', lang),
                    excludeSemantics: true,
                    child: ElevatedButton(
                      onPressed: () {
                        _saveCustomer(context,lang);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        l10n.registerButton,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Semantics(
                    label: tr('textButton', 'haveAccountTextBLabel', lang),
                    hint: tr('textButton', 'haveAccountTextBHint', lang),
                    excludeSemantics: true,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginCustomer()),
                        );
                      },
                      child: Text(
                        l10n.registerHaveAccount,
                        style: const TextStyle(color: Colors.pink),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
