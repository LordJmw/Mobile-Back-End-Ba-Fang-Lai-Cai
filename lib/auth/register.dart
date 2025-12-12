import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/auth/registerCustomer.dart';
import 'package:projek_uts_mbr/auth/registerVendor.dart';
import 'package:projek_uts_mbr/helper/semantics.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isVendor = false;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 140,
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
                child: Icon(
                  Icons.person_add_alt_1,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: Semantics(
                    label: isVendor
                        ? tr('button', 'pendaftaranCustomerButtonTLabel', lang)
                        : tr('button', 'pendaftaranCustomerButtonFLabel', lang),
                    hint: isVendor
                        ? tr('button', 'pendaftaranCustomerButtonTHint', lang)
                        : tr('button', 'pendaftaranCustomerButtonFHint', lang),
                    excludeSemantics: true,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isVendor = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isVendor ? Colors.grey : Colors.pink,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Register Customer',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Semantics(
                    label: isVendor
                        ? tr('button', 'pendaftaranVendorButtonTLabel', lang)
                        : tr('button', 'pendaftaranVendorButtonFLabel', lang),
                    hint: isVendor
                        ? tr('button', 'pendaftaranVendorButtonTHint', lang)
                        : tr('button', 'pendaftaranVendorButtonFHint', lang),
                    excludeSemantics: true,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isVendor = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isVendor ? Colors.pink : Colors.grey,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Register Vendor',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 30),
            isVendor ? RegisterVendor() : RegisterCustomer(),
          ],
        ),
      ),
    );
  }
}
