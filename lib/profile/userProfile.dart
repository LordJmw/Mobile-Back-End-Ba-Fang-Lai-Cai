import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projek_uts_mbr/analytics/eventLogs.dart';
import 'package:projek_uts_mbr/auth/loginCostumer.dart';
import 'package:projek_uts_mbr/databases/customerDatabase.dart';
import 'package:projek_uts_mbr/databases/purchaseHistoryDatabase.dart';
import 'package:projek_uts_mbr/helper/semantics.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/model/CustomerModel.dart';
import 'package:projek_uts_mbr/model/purchaseHistoryModel.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';
import 'package:projek_uts_mbr/settings_screens/settings_page.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late StreamController<CustomerModel?> _customerController;
  late StreamController<List<PurchaseHistory>> _purchaseHistoryController;
  final CustomerDatabase customerDb = CustomerDatabase();
  final Purchasehistorydatabase purchaseDb = Purchasehistorydatabase();
  final SessionManager sessionManager = SessionManager();
  File? _image;

  @override
  void initState() {
    super.initState();
    _customerController = StreamController<CustomerModel?>();
    _purchaseHistoryController = StreamController<List<PurchaseHistory>>();
    _loadCustomerData();
  }

  @override
  void dispose() {
    _customerController.close();
    _purchaseHistoryController.close();
    super.dispose();
  }

  Future<void> _logout() async {
    final session = SessionManager();
    await session.logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginCustomer()),
      (route) => false,
    );
  }

  Future<void> _loadCustomerData() async {
    try {
      // final String? customerEmail = await sessionManager.getEmail();

      final customer = await CustomerDatabase().getCurrentCustomer();
      if (customer != null) {
        // final customer = await customerDb.getCustomerByEmail(customerEmail);
        print('customer loaded: $customer');
        if (!_customerController.isClosed) {
          _customerController.add(customer);
        }

        // Load purchase history jika customer ditemukan
        if (customer != null) {
          print("di profule ad cust");
          await _loadPurchaseHistory();
        }
      } else {
        if (!_customerController.isClosed) {
          _customerController.add(null);
        }
        if (!_purchaseHistoryController.isClosed) {
          _purchaseHistoryController.add([]);
        }
      }
    } catch (e) {
      print("Error loading customer data: $e");
      if (!_customerController.isClosed) {
        _customerController.addError(e);
      }
    }
  }

  Future<void> _loadPurchaseHistory() async {
    try {
      // Cek apakah user sudah login
      final user = await CustomerDatabase().getCurrentCustomer();
      if (user == null) {
        print("User belum login, tidak bisa load purchase history");
        if (!_purchaseHistoryController.isClosed) {
          _purchaseHistoryController.add([]);
        }
        return;
      }
      print("purchase database fi userprogile");
      final history = await purchaseDb.getPurchaseHistory();
      print("Loaded ${history.length} purchase history items");

      if (!_purchaseHistoryController.isClosed) {
        _purchaseHistoryController.add(history);
      }
    } catch (e) {
      print("Error loading purchase history: $e");
      if (!_purchaseHistoryController.isClosed) {
        _purchaseHistoryController.add([]); // Kembalikan list kosong jika error
      }
    }
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
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImageStorage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImageCamera();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editProfile(BuildContext context) async {
    try {
      final String? customerEmail = await sessionManager.getEmail();
      print('pengecekkan email session manager : $customerEmail');
      if (customerEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(AppLocalizations.of(context)!.failedToLoadCustomer),
          ),
        );
        return;
      }

      final currentCustomer = await customerDb.getCustomerByEmail(
        customerEmail,
      );
      if (currentCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(AppLocalizations.of(context)!.customerNotFound),
          ),
        );
        return;
      }

      TextEditingController namaController = TextEditingController(
        text: currentCustomer.nama,
      );
      TextEditingController emailController = TextEditingController(
        text: currentCustomer.email,
      );
      TextEditingController teleponController = TextEditingController(
        text: currentCustomer.telepon,
      );
      TextEditingController alamatController = TextEditingController(
        text: currentCustomer.alamat,
      );

      await showDialog(
        context: context,
        builder: (context) {
          final lang = Provider.of<LanguageProvider>(context).locale;
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.editProfile),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    container: true,
                    focusable: true,
                    label: tr('textField', 'namaLabel', lang),
                    hint: tr('textField', 'editNamaLengkapHint', lang),
                    child: ExcludeSemantics(
                      child: TextField(
                        controller: namaController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.fullName,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // TextField(
                  //   controller: emailController,
                  //   decoration: const InputDecoration(
                  //     labelText: "Email",
                  //     border: OutlineInputBorder(),
                  //     prefixIcon: Icon(Icons.email),
                  //   ),
                  //   keyboardType: TextInputType.emailAddress,
                  // ),
                  const SizedBox(height: 12),
                  Semantics(
                    container: true,
                    focusable: true,
                    label: tr('textField', 'teleponLabel', lang),
                    hint: tr('textField', 'editTeleponHint', lang),
                    child: ExcludeSemantics(
                      child: TextField(
                        controller: teleponController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.phoneNumber,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    container: true,
                    focusable: true,
                    label: tr('textField', 'alamatLabel', lang),
                    hint: tr('textField', 'editAlamatHint', lang),
                    child: ExcludeSemantics(
                      child: TextField(
                        controller: alamatController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.address,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Semantics(
                container: true,
                focusable: true,
                label: tr('button', 'batalkanPerubahanLabel', lang),
                hint: tr('button', 'batalkanPerubahanHint', lang),
                button: true,
                child: ExcludeSemantics(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                ),
              ),
              Semantics(
                container: true,
                focusable: true,
                label: tr('button', 'simpanPerubahanLabel', lang),
                hint: tr('button', 'simpanPerubahanHint', lang),
                button: true,
                child: ExcludeSemantics(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validasi input
                      if (namaController.text.isEmpty ||
                          emailController.text.isEmpty ||
                          teleponController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              AppLocalizations.of(context)!.requiredFields,
                            ),
                          ),
                        );
                        return;
                      }

                      try {
                        String? imageUrl = currentCustomer.fotoProfil;
                        if (_image != null) {
                          final storageRef = FirebaseStorage.instance
                              .ref()
                              .child('profile_pictures')
                              .child('${currentCustomer.id}.jpg');
                          await storageRef.putFile(_image!);
                          imageUrl = await storageRef.getDownloadURL();
                        }

                        final updatedCustomer = CustomerModel(
                          id: currentCustomer.id,
                          nama: namaController.text,
                          email: emailController.text,
                          password: currentCustomer.password,
                          telepon: teleponController.text,
                          alamat: alamatController.text,
                          fotoProfil: imageUrl,
                        );

                        final result = await customerDb.updateCustomerProfile(
                          updatedCustomer,
                        );

                        if (result) {
                          await Eventlogs().logProfileEdited(
                            customerEmail,
                            "customer",
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.profileUpdatedSuccessfully,
                              ),
                            ),
                          );

                          Navigator.pop(context);
                          await _refreshData();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.failedToUpdateProfile,
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        print("Error updating profile: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text("Error: $e"),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.save,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error loading customer for edit: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text("Error: $e")),
      );
    }
  }

  Future<void> _refreshData() async {
    await _loadCustomerData();
  }

  Future<void> _editPurchase(PurchaseHistory purchase) async {
    final details = purchase.purchaseDetails;

    TextEditingController locationController = TextEditingController(
      text: details.location ?? '',
    );
    TextEditingController notesController = TextEditingController(
      text: details.notes ?? '',
    );
    DateTime? selectedDate = details.date;

    await showDialog(
      context: context,
      builder: (context) {
        final lang = Provider.of<LanguageProvider>(context).locale;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.editOrder),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.eventDate,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Semantics(
                      label: tr('button', 'selectDateLabel', lang),
                      hint: tr('button', 'selectDateHint', lang),
                      child: InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            selectedDate == null
                                ? AppLocalizations.of(context)!.selectDate
                                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      AppLocalizations.of(context)!.location,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Semantics(
                      container: true,
                      focusable: true,
                      label: tr('textField', 'locationLabel', lang),
                      hint: tr('textField', 'enterEventLocationHint', lang),
                      child: ExcludeSemantics(
                        child: TextField(
                          controller: locationController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: AppLocalizations.of(
                              context,
                            )!.enterEventLocation,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      AppLocalizations.of(context)!.specialNotes,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Semantics(
                      container: true,
                      focusable: true,
                      label: tr('textField', 'notesLabel', lang),
                      hint: tr('textField', 'addNotesHint', lang),
                      child: ExcludeSemantics(
                        child: TextField(
                          controller: notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: AppLocalizations.of(context)!.addNotes,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Semantics(
                  container: true,
                  focusable: true,
                  label: tr('button', 'cancelEditOrderLabel', lang),
                  hint: tr('button', 'cancelEditOrderHint', lang),
                  button: true,
                  child: ExcludeSemantics(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                  ),
                ),
                Semantics(
                  container: true,
                  focusable: true,
                  label: tr('button', 'saveEditOrderLabel', lang),
                  hint: tr('button', 'saveEditOrderHint', lang),
                  button: true,
                  child: ExcludeSemantics(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (selectedDate == null ||
                            locationController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.locationAndDateRequired,
                              ),
                            ),
                          );
                          return;
                        }

                        try {
                          final updatedDetails = PurchaseDetails(
                            vendor: details.vendor,
                            packageName: details.packageName,
                            price: details.price,
                            date: selectedDate!,
                            location: locationController.text,
                            notes: notesController.text,
                            status: details.status,
                          );

                          final updatedPurchase = PurchaseHistory(
                            id: purchase.id,
                            customerId: purchase.customerId,
                            purchaseDetails: updatedDetails,
                            purchaseDate: DateTime.now(),
                          );

                          await purchaseDb.updatePurchaseHistory(
                            updatedPurchase,
                          );

                          await Eventlogs().editPaket(
                            updatedPurchase.id,
                            updatedPurchase.customerId!,
                            updatedPurchase.purchaseDetails,
                            updatedPurchase.purchaseDate,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.orderUpdatedSuccessfully,
                              ),
                            ),
                          );

                          Navigator.pop(context);
                          await _refreshData(); // Refresh data setelah edit
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text("Error: $e"),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.save,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deletePurchase(
    BuildContext context,
    int purchaseId,
    String vendorName,
  ) async {
    final lang = Provider.of<LanguageProvider>(context).locale;
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.deleteOrder),
            content: Text(
              "${AppLocalizations.of(context)!.confirmDelete} $vendorName?",
            ),
            actions: [
              Semantics(
                container: true,
                focusable: true,
                label: tr('button', 'cancelDeleteOrderLabel', lang),
                hint: tr('button', 'cancelDeleteOrderHint', lang),
                button: true,
                child: ExcludeSemantics(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                ),
              ),
              Semantics(
                container: true,
                focusable: true,
                label: tr('button', 'confirmDeleteOrderLabel', lang),
                hint: tr('button', 'confirmDeleteOrderHint', lang),
                button: true,
                child: ExcludeSemantics(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.delete,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await purchaseDb.deletePurchaseHistory(purchaseId);
        await Eventlogs().deletePaket(purchaseId, vendorName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              AppLocalizations.of(context)!.orderDeletedSuccessfully,
            ),
          ),
        );
        await _refreshData(); // Refresh data setelah delete
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text("Error: $e")),
        );
      }
    }
  }

  Future<void> _inviteFriends(BuildContext context) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final lang = Provider.of<LanguageProvider>(context).locale;

      final permissionStatus = await FlutterContacts.requestPermission();

      if (!permissionStatus) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.permissionDenied),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            Center(child: CircularProgressIndicator(color: Colors.pink)),
      );

      final contacts = await FlutterContacts.getContacts(withProperties: true);

      Navigator.pop(context); //untuk menutup loading

      if (contacts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noContactsFound),
            backgroundColor: Colors.blue,
          ),
        );
        return;
      }

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return _buildContactsList(contacts, context);
        },
      );
    } catch (e) {
      print("Error accessing contacts: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildContactsList(List<Contact> contacts, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Provider.of<LanguageProvider>(context).locale;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.group, color: Colors.pink, size: 24),
                    SizedBox(width: 10),
                    Text(
                      l10n.inviteFriends,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Semantics(
                  label: tr('button', 'closeContactsListLabel', lang),
                  hint: tr('button', 'closeContactsListHint', lang),
                  excludeSemantics: true,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),

          // Info text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              l10n.chooseContactToInvite,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),

          SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final phoneNumber = contact.phones.isNotEmpty
                    ? contact.phones.first.normalizedNumber
                    : l10n.noPhoneNumber;

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Semantics(
                    //label: tr('listTile', 'contactItemLabel', lang, {'name': contact.displayName, 'phone': phoneNumber}),
                    hint: tr('listTile', 'contactItemHint', lang),
                    button: true,
                    child: ExcludeSemantics(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.pink[100],
                          child: Text(
                            contact.displayName.isNotEmpty
                                ? contact.displayName[0].toUpperCase()
                                : "?",
                            style: TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          contact.displayName,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(phoneNumber),
                        trailing: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.pink[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.inviteButton,
                            style: TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        onTap: () {
                          _showInviteConfirmation(context, contact);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showInviteConfirmation(BuildContext context, Contact contact) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Provider.of<LanguageProvider>(context).locale;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${l10n.inviteTitle(contact.displayName)}"),
        content: Text("${l10n.inviteMessage(contact.displayName)} "),
        actions: [
          Semantics(
            container: true,
            focusable: true,
            label: tr('button', 'cancelInviteLabel', lang),
            hint: tr('button', 'cancelInviteHint', lang),
            button: true,
            child: ExcludeSemantics(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
            ),
          ),
          Semantics(
            container: true,
            focusable: true,
            label: tr('button', 'sendInvitationLabel', lang),
            hint: tr('button', 'sendInvitationHint', lang),
            button: true,
            child: ExcludeSemantics(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showInviteSuccess(context, contact);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                child: Text(
                  l10n.sendInvitation,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInviteSuccess(BuildContext context, Contact contact) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${l10n.inviteSuccess(contact.displayName)}"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.userProfile),
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
              icon: Icon(Icons.settings),
            ),
          ),
          Semantics(
            label: tr('button', 'refreshLabel', lang),
            hint: tr('button', 'refreshHint', lang),
            excludeSemantics: true,
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
            ),
          ),
        ],
      ),
      body: StreamBuilder<CustomerModel?>(
        stream: _customerController.stream,
        builder: (context, customerSnapshot) {
          if (customerSnapshot.connectionState == ConnectionState.waiting &&
              !customerSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.pink),
            );
          }

          if (customerSnapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${customerSnapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final currentCustomer = customerSnapshot.data;

          if (currentCustomer == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    "Tidak dapat memuat data customer",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 45),
                    ),
                  ),
                ],
              ),
            );
          }

          return StreamBuilder<List<PurchaseHistory>>(
            stream: _purchaseHistoryController.stream,
            builder: (context, historySnapshot) {
              final purchaseHistory = historySnapshot.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Card(
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
                                    label: tr(
                                      'button',
                                      'editProfileLabel',
                                      lang,
                                    ),
                                    hint: tr('button', 'editProfileHint', lang),
                                    excludeSemantics: true,
                                    container: true,
                                    child: IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () {
                                        _editProfile(context);
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
                                    label: tr(
                                      'button',
                                      'profilePictureLabel',
                                      lang,
                                    ),
                                    hint: tr(
                                      'button',
                                      'profilePictureHint',
                                      lang,
                                    ),
                                    excludeSemantics: true,
                                    container: true,
                                    child: GestureDetector(
                                      onTap: () {
                                        _showPicker(context);
                                      },
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundImage: _image != null
                                            ? FileImage(_image!)
                                            : NetworkImage(
                                                    currentCustomer
                                                            .fotoProfil ??
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
                    ),
                    const SizedBox(height: 16),

                    Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Semantics(
                        label: tr('listTile', 'inviteFriendsLabel', lang),
                        hint: tr('listTile', 'inviteFriendsHint', lang),
                        button: true,
                        child: ExcludeSemantics(
                          child: ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.pink[50],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.group, color: Colors.pink),
                            ),
                            title: Text(
                              AppLocalizations.of(context)!.inviteFriends,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              AppLocalizations.of(
                                context,
                              )!.inviteFriendsDescription,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: Colors.pink,
                            ),
                            onTap: () => _inviteFriends(context),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Text(
                            l10n.yourPurchaseHistory,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (historySnapshot.connectionState ==
                        ConnectionState.waiting)
                      const Center(
                        child: CircularProgressIndicator(color: Colors.pink),
                      )
                    else if (purchaseHistory.isEmpty)
                      _buildEmptyState()
                    else
                      Column(
                        children: purchaseHistory
                            .map(
                              (purchase) =>
                                  _buildPurchaseCard(purchase, context),
                            )
                            .toList(),
                      ),

                    const SizedBox(height: 25),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final lang = Provider.of<LanguageProvider>(context).locale;
    return Semantics(
      label: tr('card', 'emptyPurchaseHistoryLabel', lang),
      hint: tr('card', 'emptyPurchaseHistoryHint', lang),
      child: Card(
        child: Container(
          padding: EdgeInsets.all(24),
          width: double.infinity,
          child: Column(
            children: [
              Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                "${AppLocalizations.of(context)!.noPurchasesYet}\n${AppLocalizations.of(context)!.pleaseBuyPackage}",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseCard(PurchaseHistory purchase, BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale;
    try {
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
                    Expanded(
                      child: Text(
                        purchase.purchaseDetails.vendor?.toString() ??
                            'Vendor tidak diketahui',
                        style: const TextStyle(
                          color: Colors.pink,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Semantics(
                      label: tr('button', 'purchaseOptionsLabel', lang),
                      hint: tr('button', 'purchaseOptionsHint', lang),
                      excludeSemantics: true,
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editPurchase(purchase);
                          } else if (value == 'delete') {
                            _deletePurchase(
                              context,
                              purchase.id!,
                              purchase.purchaseDetails.vendor.toString() ??
                                  'Vendor',
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.edit),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.delete,
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "${purchase.purchaseDetails.packageName ?? 'Paket'} - Rp ${purchase.purchaseDetails.price ?? 0}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "${AppLocalizations.of(context)!.eventDateLabel}: ${purchase.purchaseDetails.date.day}/${purchase.purchaseDetails.date.month}/${purchase.purchaseDetails.date.year}",
                ),
                Text(
                  "${AppLocalizations.of(context)!.location}: ${purchase.purchaseDetails.location ?? '-'}",
                ),
                if (purchase.purchaseDetails.notes != null &&
                    purchase.purchaseDetails.notes.isNotEmpty)
                  Text(
                    "${AppLocalizations.of(context)!.notes}: ${purchase.purchaseDetails.notes}",
                  ),
                const SizedBox(height: 8),
                Text(
                  "${AppLocalizations.of(context)!.purchaseDate}: ${purchase.purchaseDate.day}/${purchase.purchaseDate.month}/${purchase.purchaseDate.year}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print("Error parsing purchase details: $e");
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text("Error menampilkan data pembelian: $e"),
        ),
      );
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString.split('T').first;
    }
  }
}
