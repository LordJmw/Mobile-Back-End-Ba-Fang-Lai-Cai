import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/helper/semantics.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:provider/provider.dart';

class EditPackageForm extends StatefulWidget {
  final String vendorEmail;
  final String packageName;
  final Map<String, dynamic> packageData;

  const EditPackageForm({
    super.key,
    required this.vendorEmail,
    required this.packageName,
    required this.packageData,
  });

  @override
  State<EditPackageForm> createState() => _EditPackageFormState();
}

class _EditPackageFormState extends State<EditPackageForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _hargaController;
  late TextEditingController _jasaController;
  final Vendordatabase _vendorDb = Vendordatabase();

  @override
  void initState() {
    super.initState();
    _hargaController = TextEditingController(
      text: widget.packageData['harga'].toString(),
    );
    _jasaController = TextEditingController(
      text: widget.packageData['jasa'] ?? '',
    );
  }

  @override
  void dispose() {
    _hargaController.dispose();
    _jasaController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final newHarga = int.parse(_hargaController.text.trim());
      final newJasa = _jasaController.text.trim();

      final newPackageData = {'harga': newHarga, 'jasa': newJasa};

      await _vendorDb.updatePackage(
        widget.vendorEmail,
        widget.packageName,
        widget.packageName,
        newPackageData,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.packagePriceUpdated),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editPackagePrice), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Semantics(
                label: tr('textField', 'namaPaketLabel', lang),
                hint: trDropDown(
                  'textField',
                  'namaPaketHint',
                  lang,
                  widget.packageName,
                ),
                excludeSemantics: true,
                child: TextFormField(
                  initialValue: widget.packageName,
                  decoration: InputDecoration(
                    labelText: l10n.packageName,
                    border: const OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
              ),
              const SizedBox(height: 20),

              Semantics(
                label: trDropDown(
                  'textField',
                  'hargaEditLabel',
                  lang,
                  widget.packageName,
                ),
                hint: trDropDown(
                  'textField',
                  'hargaEditHint',
                  lang,
                  widget.packageName,
                ),
                excludeSemantics: true,
                child: TextFormField(
                  controller: _hargaController,
                  decoration: InputDecoration(
                    labelText: l10n.price,
                    prefixText: "Rp ",
                    border: const OutlineInputBorder(),
                    hintText: l10n.enterPackagePrice,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.priceRequired;
                    }
                    final number = int.tryParse(value);
                    if (number == null || number <= 0) {
                      return l10n.enterValidPrice;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              Semantics(
                label: tr('textField', 'deskripsiEditLabel', lang),
                hint: tr('textField', 'deskripsiEditHint', lang),
                excludeSemantics: true,
                child: TextFormField(
                  controller: _jasaController,
                  decoration: InputDecoration(
                    labelText: l10n.serviceDescription,
                    hintText: l10n.serviceExample,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.serviceDescriptionRequired;
                    }

                    final invalidSeparators = RegExp(r'[.;:/\-]');
                    if (invalidSeparators.hasMatch(value)) {
                      return l10n.useCommaSeparator;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 30),

              Semantics(
                label: tr('button', 'simpanPerubahanLabel', lang),
                hint: tr('button', 'simpanPerubahanHint', lang),
                excludeSemantics: true,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
