import 'package:flutter/material.dart';

import 'package:projek_uts_mbr/analytics/eventLogs.dart';
import 'package:projek_uts_mbr/auth/loginCostumer.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/main.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';
import '../home/home.dart';
import 'register.dart';

class LoginVendor extends StatefulWidget {
  LoginVendor({super.key});

  @override
  State<LoginVendor> createState() => _LoginVendorState();
}

class _LoginVendorState extends State<LoginVendor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> loginvendors() async {
    if (!_formKey.currentState!.validate()) return;

    final db = Vendordatabase();
    final vendor = await db.LoginVendor(
      _emailController.text,
      _passwordController.text,
    );

    final loc = AppLocalizations.of(context)!;

    if (vendor != null) {
      final sessionManager = SessionManager();
      await sessionManager.createLoginSession(vendor.email, "vendor");
      await Eventlogs().logVendorLoginActivity(_emailController.text, "vendor");

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
          backgroundColor: Colors.pink,
          content: Text(loc.invalidCredentials),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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

                        TextFormField(
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

                        const SizedBox(height: 20),

                        TextFormField(
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
                            if (value.length < 6) return loc.passwordMinLength;
                            return null;
                          },
                        ),

                        const SizedBox(height: 30),

                        ElevatedButton(
                          onPressed: () async => await loginvendors(),
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

                        const SizedBox(height: 20),

                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => RegisterPage()),
                            );
                          },
                          child: Text(
                            loc.noAccountRegister,
                            style: const TextStyle(color: Colors.pink),
                          ),
                        ),

                        TextButton(
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
