import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projek_uts_mbr/helper/semantics.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';

import 'package:projek_uts_mbr/model/VendorModel.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';
import 'package:projek_uts_mbr/auth/loginCostumer.dart';
import 'package:projek_uts_mbr/settings_screens/settings_page.dart';
import 'package:projek_uts_mbr/vendorform.dart';
import 'package:projek_uts_mbr/profile/editPackageForm.dart';
import 'package:provider/provider.dart';

class Vendorprofile extends StatefulWidget {
  const Vendorprofile({super.key});

  @override
  State<Vendorprofile> createState() => _VendorprofileState();
}

class _VendorprofileState extends State<Vendorprofile> {
  late StreamController<Vendormodel?> _vendorController;
  final Vendordatabase vendorDb = Vendordatabase();
  final SessionManager sessionManager = SessionManager();
  File? _image;

  @override
  void initState() {
    super.initState();
    _vendorController = StreamController<Vendormodel?>();
    loadVendorData();
  }

  void _showDeleteConfirmationDialog(
    Vendormodel vendor,
    String packageName,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Provider.of<LanguageProvider>(context, listen: false).locale;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteConfirmation),
          content: Text(l10n.confirmDeletePackage(packageName)),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Semantics(
              label: tr('button', 'deleteConfirmButtonLabel', lang),
              hint: tr('button', 'deleteConfirmButtonHint', lang),
              child: TextButton(
                child: Text(l10n.delete, style: TextStyle(color: Colors.red)),
                onPressed: () {
                  _deletePackage(
                    vendor.penyedia.first.email,
                    packageName,
                    context,
                  );
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePackage(
    String vendorEmail,
    String packageName,
    BuildContext context,
  ) async {
    await vendorDb.deletePackage(vendorEmail, packageName);
    final l10n = AppLocalizations.of(context)!;
    loadVendorData();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.orderDeletedSuccessfully)));
  }

  void _navigateToEditForm(
    Vendormodel vendor,
    String packageName,
    TipePaket packageData,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPackageForm(
          vendorEmail: vendor.penyedia.first.email,
          packageName: packageName,
          packageData: {"harga": packageData.harga, "jasa": packageData.jasa},
        ),
      ),
    );
    loadVendorData();
  }

  @override
  void dispose() {
    _vendorController.close();
    super.dispose();
  }

  Future<void> loadVendorData() async {
    final String? vendorEmail = await sessionManager.getEmail();
    if (vendorEmail != null) {
      final vendor = await vendorDb.getVendorByEmail(vendorEmail);
      if (!_vendorController.isClosed) {
        _vendorController.add(vendor);
      }
    } else {
      if (!_vendorController.isClosed) {
        _vendorController.add(null);
      }
    }
  }

  void tambahPaketBaru() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VendorForm()),
    );
    loadVendorData();
  }

  void _logout() async {
    await sessionManager.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginCustomer()),
      (route) => false,
    );
  }

  Future<void> _pickImageStorage(ImageSource source) async {
    final PermissionStatus statusStorage = Platform.isAndroid
        ? await Permission.photos
              .request() // Android 13+
        : await Permission.storage.request(); // Android 12 ke bawah & iOS lama

    if (statusStorage.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } else if (statusStorage.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Izin galeri dibutuhkan untuk memilih gambar."),
          backgroundColor: Colors.red,
        ),
      );
    } else if (statusStorage.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  Future<void> _pickImageCamera() async {
    final PermissionStatus statusCamera = await Permission.camera.request();

    if (statusCamera.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      // DIsimpan secara lokal karena jika menggunakan firebase storage perlu billing(bayar :>)
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } else if (statusCamera.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Izin kamera dibutuhkan untuk mengambil foto."),
          backgroundColor: Colors.red,
        ),
      );
      // sama aja pak
    } else if (statusCamera.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  void _showPicker(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context, listen: false).locale;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              Semantics(
                label: tr('button', 'galleryPickerLabel', lang),
                hint: tr('button', 'galleryPickerHint', lang),
                child: ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    _pickImageStorage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Semantics(
                label: tr('button', 'cameraPickerLabel', lang),
                hint: tr('button', 'cameraPickerHint', lang),
                child: ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    _pickImageCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateProfilePicture(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final String? vendorEmail = await sessionManager.getEmail();
    if (vendorEmail == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.vendorNotLoggedIn)));
      return;
    }

    if (_image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.noImageSelected)));
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('vendor_profile_pictures')
          .child('$vendorEmail.jpg');
      await storageRef.putFile(_image!);
      final imageUrl = await storageRef.getDownloadURL();

      await vendorDb.updateVendorImage(vendorEmail, imageUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profilePictureUpdated),
          backgroundColor: Colors.green,
        ),
      );
      loadVendorData(); // Refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToUpdatePicture(e)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vendorProfile),
        actions: [
          Semantics(
            label: tr('button', 'settingsLabel', lang),
            hint: tr('button', 'settingsHint', lang),
            excludeSemantics: true,
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
              icon: const Icon(Icons.settings),
            ),
          ),
        ],
      ),
      body: StreamBuilder<Vendormodel?>(
        stream: _vendorController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentVendor = snapshot.data;
          if (currentVendor == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    label: tr('image', 'errorIconLabel', lang),
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.failedToLoadVendor),
                  const SizedBox(height: 24),
                  Semantics(
                    label: tr('button', 'logoutButtonLabel', lang),
                    hint: tr('button', 'logoutButtonHint', lang),
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 45),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () => _showPicker(context),
                    child: Semantics(
                      label: tr('button', 'profilePictureLabel', lang),
                      hint: tr('button', 'profilePictureHint', lang),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : NetworkImage(
                                    currentVendor
                                            .penyedia
                                            .first
                                            .image
                                            .isNotEmpty
                                        ? currentVendor.penyedia.first.image
                                        : 'https://cdn-icons-png.flaticon.com/512/149/149071.png',
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
                ),
                const SizedBox(height: 10),
                Semantics(
                  label: tr('text', 'vendorNameLabel', lang),
                  child: Text(
                    currentVendor.penyedia.first.nama,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Semantics(
                  label: tr('text', 'vendorDescriptionLabel', lang),
                  child: Text(
                    currentVendor.penyedia.first.deskripsi.isNotEmpty
                        ? currentVendor.penyedia.first.deskripsi
                        : l10n.noDescription,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Semantics(
                      label: tr('image', 'starRatingLabel', lang),
                      child: Icon(Icons.star, color: Colors.amber[600]),
                    ),
                    const SizedBox(width: 5),
                    Semantics(
                      label: tr('text', 'ratingValueLabel', lang),
                      child: Text(
                        currentVendor.penyedia.first.rating.toStringAsFixed(1),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Semantics(
                        label: tr('text', 'yourPackagesTitleLabel', lang),
                        child: Text(
                          "${l10n.yourPackages} (${currentVendor.penyedia.first.nama})",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                _buildPackageList(currentVendor, context),
              ],
            ),
          );
        },
      ),
      // floatingActionButton: Semantics(
      //   label: tr('button', 'addPackageLabel', lang),
      //   hint: tr('button', 'addPackageHint', lang),
      //   child: FloatingActionButton(
      //     onPressed: tambahPaketBaru,
      //     backgroundColor: Colors.pink,
      //     foregroundColor: Colors.white,
      //     child: const Icon(Icons.add),
      //   ),
      // ),
    );
  }

  Widget _buildPackageList(Vendormodel vendor, BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale;
    final harga = vendor.penyedia.first.harga;
    final l10n = AppLocalizations.of(context)!;
    final packages = {
      "Basic": harga.basic,
      "Premium": harga.premium,
      "Custom": harga.custom,
    };

    List<Widget> packageWidgets = packages.entries.map((entry) {
      final packageName = entry.key;
      final data = entry.value;
      final hargaText = data.harga > 0 ? "Rp ${data.harga}" : l10n.priceNotSet;
      final jasaText = data.jasa.isNotEmpty ? data.jasa : l10n.noDescription;

      return Semantics(
        container: true,
        label: tr(
          'button',
          'fullPaketLabel',
          lang,
          params: {"name1" : packageName , "name2" : hargaText},
        ),
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 160,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          packageName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.pink,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          hargaText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      jasaText,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Positioned(
                  top: -10,
                  right: -10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        label: tr('button', 'editPaketButtonLabel', lang),
                        hint: tr('button', 'editPaketButtonHint', lang),
                        excludeSemantics: true,
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                            size: 20,
                          ),
                          onPressed: () {
                            _navigateToEditForm(vendor, packageName, data);
                          },
                        ),
                      ),
                      Semantics(
                        label: tr('button', 'deletePaketButtonLabel', lang),
                        hint: tr('button', 'deletePaketButtonHint', lang),
                        excludeSemantics: true,
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () {
                            _showDeleteConfirmationDialog(
                              vendor,
                              packageName,
                              context,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();

    return Column(children: [...packageWidgets, const SizedBox(height: 20)]);
  }
}
