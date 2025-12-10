import 'package:flutter/material.dart';

import 'package:projek_uts_mbr/analytics/eventLogs.dart';
import 'package:projek_uts_mbr/auth/loginVendor.dart';
import 'package:projek_uts_mbr/databases/customerDatabase.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/main.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';
import '../home/home.dart';
import 'register.dart';

class LoginCustomer extends StatefulWidget {
  LoginCustomer({super.key});

  @override
  State<LoginCustomer> createState() => _LoginCustomerState();
}

class _LoginCustomerState extends State<LoginCustomer> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> logincustomers() async {
    if (!_formKey.currentState!.validate()) return;

    final db = CustomerDatabase();

    final customer = await db.LoginCustomer(
      emailController.text,
      passwordController.text,
    );

    final t = AppLocalizations.of(context)!;

    if (customer != null) {
      final sessionManager = SessionManager();
      await sessionManager.createLoginSession(customer.email, "customer");

      final eventlogs = Eventlogs();
      await eventlogs.logLoginActivity(customer.email, "customer");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.green, content: Text(t.loginSuccess)),
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
          content: Text(t.invalidCredentials),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

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
                          t.welcome,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          t.loginToContinue,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 30),

                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined),
                            labelText: t.email,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) return t.emailRequired;

                            final regex = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );

                            if (!regex.hasMatch(value)) {
                              return t.invalidEmailFormat;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            labelText: t.password,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) return t.passwordRequired;
                            if (value.length < 6) return t.passwordMinLength;
                            return null;
                          },
                        ),

                        const SizedBox(height: 30),

                        ElevatedButton(
                          onPressed: logincustomers,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            t.login,
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
                            t.noAccountRegister,
                            style: const TextStyle(color: Colors.pink),
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => LoginVendor()),
                            );
                          },
                          child: Text(
                            t.loginAsVendor,
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
