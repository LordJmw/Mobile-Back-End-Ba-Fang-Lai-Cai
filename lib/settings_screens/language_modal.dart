import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/helper/semantics.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:provider/provider.dart';

class LanguageModal extends StatefulWidget {
  final String currentLanguage;

  const LanguageModal({Key? key, required this.currentLanguage})
    : super(key: key);

  @override
  State<LanguageModal> createState() => _LanguageModalState();
}

class _LanguageModalState extends State<LanguageModal> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Provider.of<LanguageProvider>(context).locale;
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Draggable Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Semantics(
                  label: tr('button', 'closeButtonLabel', lang),
                  hint: tr('button', 'closeButtonHint', lang),
                  excludeSemantics: true,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.chooseLanguage,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 0),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildLanguageCard(
                  language: l10n.indonesia,
                  code: 'ID',
                  description: l10n.indonesianLanguage,
                  isSelected: _selectedLanguage == 'Indonesia',
                  onTap: () => _selectLanguage('Indonesia'),
                  lang: lang,
                ),
                const SizedBox(height: 16),
                _buildLanguageCard(
                  language: l10n.english,
                  code: 'EN',
                  description: l10n.englishLanguage,
                  isSelected: _selectedLanguage == 'English',
                  onTap: () => _selectLanguage('English'),
                  lang: lang,
                ),
              ],
            ),
          ),

          // Bottom Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: Semantics(
                label: tr('button', 'saveLanguageButtonLabel', lang),
                hint: tr('button', 'saveLanguageButtonHint', lang),
                excludeSemantics: true,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedLanguage);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.save,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard({
    required String language,
    required String code,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
    required Locale lang,
  }) {
    return Semantics(
      label: tr('button', 'languageButtonLabel', lang, params: {"name" : language}),
      hint: isSelected ? 
      tr('button', 'languageButtonTHint', lang, params: {"name" : language}) :
      tr('button', 'languageButtonFHint', lang, params: {"name" : language}),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6C63FF).withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Flag/Code Circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6C63FF)
                      : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    code,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Language Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Check Icon
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: const Color(0xFF6C63FF),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });
  }
}
