import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
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
import 'package:projek_uts_mbr/profile/services/profile_service.dart';
import 'package:projek_uts_mbr/profile/widgets/profile_card.dart';
import 'package:projek_uts_mbr/profile/widgets/purchase_history_card.dart';
import 'package:projek_uts_mbr/profile/widgets/invite_friends_card.dart';
import 'package:projek_uts_mbr/profile/widgets/premium_card.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late StreamController<CustomerModel?> _customerController;
  late StreamController<List<PurchaseHistory>> _purchaseHistoryController;
  final ProfileService _profileService = ProfileService();
  final SessionManager sessionManager = SessionManager();
  final CustomerDatabase customerDb = CustomerDatabase();
  File? _image;

  @override
  void initState() {
    super.initState();
    _customerController = StreamController<CustomerModel?>();
    _purchaseHistoryController = StreamController<List<PurchaseHistory>>();
    _loadData();
  }

  @override
  void dispose() {
    _customerController.close();
    _purchaseHistoryController.close();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final customer = await _profileService.loadCustomerData();
      if (!_customerController.isClosed) {
        _customerController.add(customer);
      }
      if (customer != null) {
        final history = await _profileService.loadPurchaseHistory();
        if (!_purchaseHistoryController.isClosed) {
          _purchaseHistoryController.add(history);
        }
      } else {
        if (!_purchaseHistoryController.isClosed) {
          _purchaseHistoryController.add([]);
        }
      }
    } catch (e) {
      if (!_customerController.isClosed) {
        _customerController.addError(e);
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  Future<void> _logout() async {
    await _profileService.logout(context);
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
                onTap: () async {
                  final image = await _profileService.pickImage(
                    ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() {
                      _image = image;
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () async {
                  final image = await _profileService.pickImage(
                    ImageSource.camera,
                  );
                  if (image != null) {
                    setState(() {
                      _image = image;
                    });
                  }
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
    final customer = await _profileService.loadCustomerData();
    if (customer == null) return;

    TextEditingController namaController = TextEditingController(
      text: customer.nama,
    );
    TextEditingController teleponController = TextEditingController(
      text: customer.telepon,
    );
    TextEditingController alamatController = TextEditingController(
      text: customer.alamat,
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                String? imageUrl = customer.fotoProfil;
                if (_image != null) {
                  imageUrl = await _profileService.uploadProfilePicture(
                    _image!,
                    customer.id.toString(),
                  );
                }

                final updatedCustomer = CustomerModel(
                  id: customer.id,
                  nama: namaController.text,
                  email: customer.email,
                  password: customer.password,
                  telepon: teleponController.text,
                  alamat: alamatController.text,
                  fotoProfil: imageUrl,
                );

                final success = await _profileService.updateUserProfile(
                  updatedCustomer,
                );
                Navigator.pop(context);
                if (success) {
                  _refreshData();
                }
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
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
        final lang = Provider.of<LanguageProvider>(
          context,
          listen: false,
        ).locale;
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
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedDate == null ||
                        locationController.text.isEmpty) {
                      return;
                    }

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

                    await _profileService.updatePurchase(updatedPurchase);
                    Navigator.pop(context);
                    _refreshData();
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deletePurchase(int purchaseId, String vendorName) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.deleteOrder),
            content: Text(
              "${AppLocalizations.of(context)!.confirmDelete} $vendorName?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocalizations.of(context)!.delete),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await _profileService.deletePurchase(purchaseId, vendorName);
      _refreshData();
    }
  }

  Future<void> _inviteFriends(BuildContext context) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final lang = Provider.of<LanguageProvider>(context, listen: false).locale;

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
    final lang = Provider.of<LanguageProvider>(context, listen: false).locale;

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
    final lang = Provider.of<LanguageProvider>(context, listen: false).locale;

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
    final lang = Provider.of<LanguageProvider>(context, listen: false).locale;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.userProfile),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
            icon: Icon(Icons.settings),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
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
            return Center(child: Text('Error: ${customerSnapshot.error}'));
          }

          final currentCustomer = customerSnapshot.data;

          if (currentCustomer == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Tidak dapat memuat data customer"),
                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ProfileCard(
                  currentCustomer: currentCustomer,
                  image: _image,
                  showPicker: _showPicker,
                  editProfile: _editProfile,
                ),
                const SizedBox(height: 16),
                InviteFriendsCard(onInvite: _inviteFriends),
                const SizedBox(height: 16),
                const PremiumCard(),
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
                StreamBuilder<List<PurchaseHistory>>(
                  stream: _purchaseHistoryController.stream,
                  builder: (context, historySnapshot) {
                    if (historySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.pink),
                      );
                    }
                    final purchaseHistory = historySnapshot.data ?? [];
                    if (purchaseHistory.isEmpty) {
                      return _buildEmptyState();
                    }
                    return Column(
                      children: purchaseHistory
                          .map(
                            (purchase) => PurchaseHistoryCard(
                              purchase: purchase,
                              onEdit: _editPurchase,
                              onDelete: _deletePurchase,
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 25),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
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
    );
  }
}
