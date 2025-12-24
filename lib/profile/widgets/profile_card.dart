import 'dart:io';
import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/model/CustomerModel.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/helper/semantics.dart';
import 'package:provider/provider.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';

class ProfileCard extends StatelessWidget {
  final CustomerModel currentCustomer;
  final File? image;
  final Function(BuildContext) showPicker;
  final Function(BuildContext) editProfile;

  const ProfileCard({
    super.key,
    required this.currentCustomer,
    this.image,
    required this.showPicker,
    required this.editProfile,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context, listen: false).locale;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.myProfile,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const Spacer(),
                  Semantics(
                    label: tr('button', 'editProfileLabel', lang),
                    hint: tr('button', 'editProfileHint', lang),
                    excludeSemantics: true,
                    container: true,
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () {
                        editProfile(context);
                      },
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    label: tr('button', 'profilePictureLabel', lang),
                    hint: tr('button', 'profilePictureHint', lang),
                    excludeSemantics: true,
                    container: true,
                    child: GestureDetector(
                      onTap: () {
                        showPicker(context);
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: image != null
                            ? FileImage(image!)
                            : NetworkImage(
                                    currentCustomer.fotoProfil ??
                                        'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                                  )
                                  as ImageProvider,
                        child: const Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 15,
                            child: Icon(
                              Icons.camera_alt,
                              size: 15,
                              color: Colors.pink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                currentCustomer.nama,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(height: 8),
              Text("Email: ${currentCustomer.email}"),
              Text(
                "${AppLocalizations.of(context)!.phone}: ${currentCustomer.telepon}",
              ),
              Text(
                "${AppLocalizations.of(context)!.address}: ${currentCustomer.alamat}",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
