import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:projek_uts_mbr/analytics/eventLogs.dart';
import 'package:projek_uts_mbr/auth/logincostumer.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/helper/semantics.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:provider/provider.dart';

class RegisterVendor extends StatefulWidget {
  const RegisterVendor({super.key});

  @override
  State<RegisterVendor> createState() => _RegisterVendorState();
}

class _RegisterVendorState extends State<RegisterVendor> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namatokoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _hargaBasicController = TextEditingController();
  final TextEditingController _jasaBasicController = TextEditingController();
  final TextEditingController _hargaPremiumController = TextEditingController();
  final TextEditingController _jasaPremiumController = TextEditingController();
  final TextEditingController _hargaCustomController = TextEditingController();
  final TextEditingController _jasaCustomController = TextEditingController();

  String? selectedCategory;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<bool> _askContactPermission(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    var status = await Permission.contacts.status;

    if (status.isGranted) return true;

    status = await Permission.contacts.request();
    if (status.isGranted) return true;

    if (status.isDenied) {
      final retry = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.permissionContactRequired),
          content: Text(l10n.permissionContactRequiredMessage),
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
        ),
      );

      if (retry == true) {
        status = await Permission.contacts.request();
        if (status.isGranted) return true;
      }
    }

    if (status.isPermanentlyDenied) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.permissionDitolakPermanenTitle),
          content: Text(l10n.permissionDitolakPermanenMessage),
          actions: [
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.pop(context);
              },
              child: Text(l10n.bukaPengaturan),
            ),
          ],
        ),
      );
    }

    return false;
  }

  Future<void> _loadCategories() async {
    final db = Vendordatabase();
    await db.initDataAwal();
    final cats = await db.getCategories();
    setState(() {
      categories = cats;
    });
  }

  Future<void> _saveVendor(BuildContext context,lang) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()){
      if (_namatokoController.text.isEmpty &&
      _emailController.text.isEmpty &&
      _teleponController.text.isEmpty &&
      selectedCategory == null &&
      _alamatController.text.isEmpty &&
      _deskripsiController.text.isEmpty &&
      _hargaBasicController.text.isEmpty &&
      _jasaBasicController.text.isEmpty &&
      _hargaPremiumController.text.isEmpty &&
      _jasaPremiumController.text.isEmpty &&
      _hargaCustomController.text.isEmpty &&
      _jasaCustomController.text.isEmpty &&
      _passwordController.text.isEmpty &&
      _confirmController.text.isEmpty) {
        SemanticsService.announce(
          tr('button', 'registerKosong', lang),
          TextDirection.ltr,
        );
      return;
    }
      if (_namatokoController.text.isEmpty) {
        SemanticsService.announce(
          tr('button', 'namaTokoKosong', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (_emailController.text.isEmpty) {
        SemanticsService.announce(
          tr('button', 'emailKosong', lang),
          TextDirection.ltr,
        );
        return;
      }

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(_emailController.text)) {
        SemanticsService.announce(
          tr('button', 'emailFormatSalah', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (_teleponController.text.isEmpty) {
        SemanticsService.announce(
          tr('button', 'teleponKosong', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (!RegExp(r'^[0-9]+$').hasMatch(_teleponController.text)) {
        SemanticsService.announce(
          tr('button', 'teleponFormatSalah', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (selectedCategory == null) {
        SemanticsService.announce(
          tr('button', 'kategoriKosong', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (_alamatController.text.isEmpty) {
        SemanticsService.announce(
          tr('button', 'alamatKosong', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (_deskripsiController.text.isEmpty) {
        SemanticsService.announce(
          tr('button', 'deskripsiKosong', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (_hargaBasicController.text.isEmpty) {
        SemanticsService.announce(
          tr('button', 'hargaKosong', lang),
          TextDirection.ltr,
        );
        return;
      }

      final hb = int.tryParse(_hargaBasicController.text);
      if (hb == null) {
        SemanticsService.announce(
          tr('button', 'hargaTidakValid', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (hb > 10000000) {
        SemanticsService.announce(
          tr('button', 'hargaTerlaluBesar', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (_jasaBasicController.text.isEmpty) {
        SemanticsService.announce(
          tr('button', 'jasaKosong', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (_hargaPremiumController.text.isEmpty) {
        SemanticsService.announce(
          tr('button', 'hargaKosong', lang),
          TextDirection.ltr,
        );
        return;
      }

      final hp = int.tryParse(_hargaPremiumController.text);
      if (hp == null) {
        SemanticsService.announce(
          tr('button', 'hargaTidakValid', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (hp > 10000000) {
        SemanticsService.announce(
          tr('button', 'hargaTerlaluBesar', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (_jasaPremiumController.text.isEmpty) {
        SemanticsService.announce(
          tr('button', 'jasaKosong', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (_hargaCustomController.text.isEmpty) {
        SemanticsService.announce(
          tr('button', 'hargaKosong', lang),
          TextDirection.ltr,
        );
        return;
      }

      final hc = int.tryParse(_hargaCustomController.text);
      if (hc == null) {
        SemanticsService.announce(
          tr('button', 'hargaTidakValid', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (hc > 10000000) {
        SemanticsService.announce(
          tr('button', 'hargaTerlaluBesar', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (_jasaCustomController.text.isEmpty) {
        SemanticsService.announce(
          tr('button', 'jasaKosong', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (_passwordController.text.isEmpty) {
        SemanticsService.announce(
          tr('button', 'passwordKosong', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (_passwordController.text.length < 6) {
        SemanticsService.announce(
          tr('button', 'passwordPendek', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (_confirmController.text.isEmpty) {
        SemanticsService.announce(
          tr('button', 'confirmKosong', lang),
          TextDirection.ltr,
        );
        return;
      }

      if (_confirmController.text != _passwordController.text) {
        SemanticsService.announce(
          tr('button', 'passwordTidakSama', lang),
          TextDirection.ltr,
        );
        return;
      }
      return;
    }

    final penyedia = Penyedia(
      nama: _namatokoController.text,
      deskripsi: _deskripsiController.text,
      rating: 0.0,
      harga: Harga(
        basic: TipePaket(
          harga: int.parse(_hargaBasicController.text),
          jasa: _jasaBasicController.text,
        ),
        premium: TipePaket(
          harga: int.parse(_hargaPremiumController.text),
          jasa: _jasaPremiumController.text,
        ),
        custom: TipePaket(
          harga: int.parse(_hargaCustomController.text),
          jasa: _jasaCustomController.text,
        ),
      ),
      testimoni: [],
      email: _emailController.text,
      password: _passwordController.text,
      telepon: _teleponController.text,
      image: "https://cdn-icons-png.flaticon.com/512/149/149071.png",
    );

    final vendor = Vendormodel(
      kategori: selectedCategory ?? "",
      penyedia: [penyedia],
    );

    final db = Vendordatabase();
    await db.insertVendor(vendor);

    bool granted = await _askContactPermission(context);
    if (!granted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.registerVendorSuccess),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginCustomer()),
    );
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
                    l10n.registerVendorTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Semantics(
                    label: tr('textField', 'namaTokoLabel', lang),
                    hint: tr('textField', 'namaTokoHint', lang),
                    excludeSemantics: true,
                    child: TextFormField(
                      controller: _namatokoController,
                      decoration: InputDecoration(
                        labelText: l10n.registerVendorName,
                        prefixIcon: const Icon(Icons.store_outlined),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? l10n.errorNameRequired : null,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Semantics(
                    label: tr('textField', 'emailLabel', lang),
                    hint: tr('textField', 'emailHint', lang),
                    excludeSemantics: true,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: l10n.registerVendorEmail,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v!.isEmpty) return l10n.errorEmailRequired;
                        final regex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!regex.hasMatch(v)) return l10n.errorEmailInvalid;
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Semantics(
                    label: tr('textField', 'teleponLabel', lang),
                    hint: tr('textField', 'teleponHint', lang),
                    excludeSemantics: true,
                    child: TextFormField(
                      controller: _teleponController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: l10n.registerVendorPhone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                      validator: (v) {
                        if (v!.isEmpty) return l10n.errorPhoneRequired;
                        if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
                          return l10n.errorPhoneOnlyNumber;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Semantics(
                    label: selectedCategory == null
                        ? tr("textField", "kategoriTokoLabelT", lang)
                        : tr(
                            'textField',
                            "kategoriTokoLabelF",
                            lang,
                            params: {'name' : '$selectedCategory'},
                          ),
                    hint: selectedCategory == null
                        ? tr("textField", "kategoriTokoHintT", lang)
                        : tr("textField", "kategoriTokoHintF", lang),
                    excludeSemantics: true,
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: l10n.categoryPage,
                        prefixIcon: const Icon(Icons.category_outlined),
                      ),
                      items: categories
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Semantics(
                                label: tr('textField', 'vendorCategoryItemLabel', lang, params: {"name" : e} ),
                                excludeSemantics: true,
                                child: Text(e),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedCategory = v),
                      validator: (v) => v == null ? l10n.requiredFields : null,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Semantics(
                    label: tr('textField', 'alamatLabel', lang),
                    hint: tr('textField', 'alamatHint', lang),
                    excludeSemantics: true,
                    child: TextFormField(
                      controller: _alamatController,
                      decoration: InputDecoration(
                        labelText: l10n.registerVendorAddress,
                        prefixIcon: const Icon(Icons.home_outlined),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? l10n.errorAddressRequired : null,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Semantics(
                    label: tr('textField', 'deskripsiTokoLabel', lang),
                    hint: tr('textField', 'deskripsiTokoHint', lang),
                    excludeSemantics: true,
                    child: TextFormField(
                      controller: _deskripsiController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: l10n.description,
                        prefixIcon: const Icon(Icons.description_outlined),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? l10n.serviceDescriptionRequired : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.paketBasic,
                    style: const TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Semantics(
                    label: tr('textField', 'hargaLabel', lang, params: {"name" : 'Basic'}),
                    hint: tr('textField', 'hargaHint', lang,params: {"name" : 'Basic'}),
                    excludeSemantics: true,
                    child: TextFormField(
                      controller: _hargaBasicController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: l10n.hargaBasic),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return l10n.hargaBasicWajibDiisi;
                        final value = int.tryParse(v);
                        if (value == null) return l10n.hargaTidakValid;
                        if (value > 10000000)
                          return l10n.hargaTidakBolehLebihDari10Juta;
                        return null;
                      },
                    ),
                  ),
                  Semantics(
                    label: tr('textField', 'jasaLabel', lang, params : {"name" : 'Basic'}),
                    hint: tr('textField', 'jasaHint', lang, params : {"name" : 'Basic'}),
                    excludeSemantics: true,
                    child: TextFormField(
                      controller: _jasaBasicController,
                      decoration: InputDecoration(labelText: l10n.jasaBasic),
                      validator: (v) =>
                          v!.isEmpty ? l10n.jasaBasicWajibDiisi : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.paketPremium,
                    style: const TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Semantics(
                    label: tr('textField', 'hargaLabel', lang, params: {"name" : 'Premium'}),
                    hint: tr('textField', 'hargaHint', lang,params: {"name" : 'Premium'}),
                    excludeSemantics: true,
                    child: TextFormField(
                      controller: _hargaPremiumController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: l10n.hargaPremium),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return l10n.hargaPremiumWajibDiisi;
                        final value = int.tryParse(v);
                        if (value == null) return l10n.hargaTidakValid;
                        if (value > 10000000)
                          return l10n.hargaTidakBolehLebihDari10Juta;
                        return null;
                      },
                    ),
                  ),
                  Semantics(
                    label: tr('textField', 'jasaLabel', lang, params: {"name" : 'Premium'}),
                    hint: tr('textField', 'jasaHint', lang, params: {"name" : 'Premium'}),
                    excludeSemantics: true,
                    child: TextFormField(
                      controller: _jasaPremiumController,
                      decoration: InputDecoration(labelText: l10n.jasaPremium),
                      validator: (v) =>
                          v!.isEmpty ? l10n.jasaPremiumWajibDiisi : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.paketCustom,
                    style: const TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Semantics(
                    label: tr('textField', 'hargaLabel', lang, params: {"name" : 'Custom'}),
                    hint: tr('textField', 'hargaHint', lang, params: {"name" : 'Custom'}),
                    excludeSemantics: true,
                    child: TextFormField(
                      controller: _hargaCustomController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: l10n.hargaCustom),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return l10n.hargaCustomWajibDiisi;
                        final value = int.tryParse(v);
                        if (value == null) return l10n.hargaTidakValid;
                        if (value > 10000000)
                          return l10n.hargaTidakBolehLebihDari10Juta;
                        return null;
                      },
                    ),
                  ),
                  Semantics(
                    label: tr('textField', 'jasaLabel', lang, params: {"name" : 'Custom'}),
                    hint: tr('textField', 'jasaHint', lang, params: {"name" : 'Custom'}),
                    excludeSemantics: true,
                    child: TextFormField(
                      controller: _jasaCustomController,
                      decoration: InputDecoration(labelText: l10n.jasaCustom),
                      validator: (v) =>
                          v!.isEmpty ? l10n.jasaCustomWajibDiisi : null,
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
                        labelText: l10n.registerVendorPassword,
                      ),
                      validator: (v) => v == null || v.length < 6
                          ? l10n.errorPasswordMinLength
                          : null,
                    ),
                  ),
                  Semantics(
                    label: tr('textField', 'confirmPasswordLabel', lang),
                    hint: tr('textField', 'confirmPasswordHint', lang),
                    excludeSemantics: true,
                    child: TextFormField(
                      controller: _confirmController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.registerVendorConfirmPassword,
                      ),
                      validator: (v) => v != _passwordController.text
                          ? l10n.errorPasswordNotMatch
                          : null,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Semantics(
                    label: tr('button', 'registerAkunButtonLabel', lang),
                    hint: tr('button', 'registerAkunButtonHint', lang),
                    excludeSemantics: true,
                    child: ElevatedButton(
                      onPressed: () {
                        _saveVendor(context,lang);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        l10n.registerVendorButton,
                        style: const TextStyle(color: Colors.white),
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
