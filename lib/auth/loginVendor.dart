import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:projek_uts_mbr/analytics/eventLogs.dart';
import 'package:projek_uts_mbr/auth/loginCostumer.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/helper/semantics.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/main.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';
import 'package:provider/provider.dart';
import '../home/home.dart';
import 'register.dart';

class LoginVendor extends StatefulWidget {
  final Vendordatabase vendordatabase;
  final SessionManager sessionManager;
  final Eventlogs eventlogs;

  LoginVendor({
    super.key,
    Vendordatabase? vendordatabase,
    SessionManager? sessionManager,
    Eventlogs? eventlogs,
  }) : vendordatabase = vendordatabase ?? Vendordatabase(),
       sessionManager = sessionManager ?? SessionManager(),
       eventlogs = eventlogs ?? Eventlogs();

  @override
  State<LoginVendor> createState() => _LoginVendorState();
}

class _LoginVendorState extends State<LoginVendor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> loginvendors(lang) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (!_formKey.currentState!.validate()) {
      if (email.isEmpty && password.isEmpty) {
        SemanticsService.announce(
          tr('button', 'loginKosong', lang),
          TextDirection.ltr,
        );
        return;
      }
      if (email.isEmpty) {
        SemanticsService.announce(
          tr('button', 'emailkosong', lang),
          TextDirection.ltr,
        );
        return;
      }
      if (password.isEmpty) {
        SemanticsService.announce(
          tr('button', 'passwordkosong', lang),
          TextDirection.ltr,
        );
        return;
      }
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        SemanticsService.announce(
          tr('button', 'emailFormatSalah', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (password.length < 6) {
        SemanticsService.announce(
          tr('button', 'passwordPendek', lang),
          TextDirection.ltr,
        );
        return;
      }
      return;
    }

    final vendor = await widget.vendordatabase.LoginVendor(
      _emailController.text,
      _passwordController.text,
    );

    final loc = AppLocalizations.of(context)!;

    if (vendor != null) {
      await widget.sessionManager.createLoginSession(vendor.email, "vendor");
      await widget.eventlogs.logVendorLoginActivity(
        _emailController.text,
        "vendor",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(loc.loginSuccess),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const Key('invalid_credentials_snackbar'),
          backgroundColor: Colors.pink,
          content: Text(loc.invalidCredentials),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink, Colors.pinkAccent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: const Center(
                child: Icon(Icons.lock_outline, size: 80, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          loc.welcome,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          loc.loginToContinue,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 30),
                        Semantics(
                          label: tr('textField', 'emailLabel', lang),
                          hint: tr('textField', 'emailHint', lang),
                          excludeSemantics: true,
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email_outlined),
                              labelText: loc.email,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) return loc.emailRequired;

                              final regex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );

                              if (!regex.hasMatch(value)) {
                                return loc.invalidEmailFormat;
                              }
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
                              labelText: loc.password,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) return loc.passwordRequired;
                              if (value.length < 6)
                                return loc.passwordMinLength;
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        Semantics(
                          label: tr('button', 'loginAkunButtonLabel', lang),
                          hint: tr('button', 'loginAkunButtonHint', lang),
                          excludeSemantics: true,
                          child: ElevatedButton(
                            onPressed: () async => await loginvendors(lang),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              loc.login,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Semantics(
                          label: tr(
                            'textButton',
                            'registerAkunTextBLabel',
                            lang,
                          ),
                          hint: tr('textButton', 'registerAkunTextBHint', lang),
                          excludeSemantics: true,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RegisterPage(),
                                ),
                              );
                            },
                            child: Text(
                              loc.noAccountRegister,
                              style: const TextStyle(color: Colors.pink),
                            ),
                          ),
                        ),
                        Semantics(
                          label: tr(
                            'textButton',
                            'loginAsCustomerTextBLabel',
                            lang,
                          ),
                          hint: tr(
                            'textButton',
                            'loginAsCustomerTextBHint',
                            lang,
                          ),
                          excludeSemantics: true,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LoginCustomer(),
                                ),
                              );
                            },
                            child: Text(
                              loc.loginAsCustomer,
                              style: const TextStyle(
                                color: Colors.pink,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.pink,
                                decorationThickness: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
