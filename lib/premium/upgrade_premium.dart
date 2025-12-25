import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/databases/customerDatabase.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/helper/semantics.dart';
import 'package:projek_uts_mbr/model/CustomerModel.dart';
import 'package:projek_uts_mbr/services/notification_services.dart';
import 'package:projek_uts_mbr/services/premium_services.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';
import 'package:projek_uts_mbr/settings_screens/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';

class PremiumUpgradePage extends StatefulWidget {
  const PremiumUpgradePage({super.key});

  @override
  State<PremiumUpgradePage> createState() => _PremiumUpgradePageState();
}

class _PremiumUpgradePageState extends State<PremiumUpgradePage> {
  String _selectedPlan = 'yearly'; // 'monthly' or 'yearly'
  bool _isProcessing = false;

  // Dummy payment method
  String _selectedPaymentMethod = 'gopay';

  // Harga
  final Map<String, Map<String, dynamic>> _plans = {
    'monthly': {'price': 29900, 'pricePerMonth': 29900, 'savePercent': 0},
    'yearly': {'price': 299000, 'pricePerMonth': 24917, 'savePercent': 17},
  };

  // Dummy payment methods
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'gopay',
      'nameKey': 'paymentMethodGopay',
      'icon': Icons.account_balance_wallet,
      'color': Color(0xFF00AA13),
    },
    {
      'id': 'ovo',
      'nameKey': 'paymentMethodOvo',
      'icon': Icons.account_balance_wallet,
      'color': Color(0xFF4C2A86),
    },
    {
      'id': 'dana',
      'nameKey': 'paymentMethodDana',
      'icon': Icons.account_balance_wallet,
      'color': Color(0xFF1081E8),
    },
    {
      'id': 'bank_transfer',
      'nameKey': 'paymentMethodBankTransfer',
      'icon': Icons.account_balance,
      'color': Colors.blueGrey,
    },
    {
      'id': 'credit_card',
      'nameKey': 'paymentMethodCreditCard',
      'icon': Icons.credit_card,
      'color': Colors.deepPurple,
    },
  ];

  // Features list
  final List<Map<String, dynamic>> _premiumFeatures = [
    {
      'icon': Icons.block,
      'titleKey': 'premiumFeatureNoAds',
      'descKey': 'premiumFeatureNoAdsDesc',
      'color': Colors.red,
    },
    {
      'icon': Icons.stars,
      'titleKey': 'premiumFeatureBadge',
      'descKey': 'premiumFeatureBadgeDesc',
      'color': Colors.amber,
    },
    {
      'icon': Icons.support_agent,
      'titleKey': 'premiumFeaturePriority',
      'descKey': 'premiumFeaturePriorityDesc',
      'color': Colors.green,
    },
    {
      'icon': Icons.new_releases,
      'titleKey': 'premiumFeatureEarlyAccess',
      'descKey': 'premiumFeatureEarlyAccessDesc',
      'color': Colors.blue,
    },
  ];

  Future<void> _processUpgrade() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final notifStatus = await SessionManager().getNotificationStatus();
      if (notifStatus != true) {
        //kalau notif nya belum di set allow oleh user tidak akan diproses
        if (!mounted) return;
        //tampilkan snackbar yang menyuruh user mengaktifkan notif
        _showEnableNotificationSnackBar();

        setState(() => _isProcessing = false);
        return;
      }
      //jika sudah di allow maka akan diproses
      final premiumService = PremiumService();
      final customerDatabase = CustomerDatabase();

      final customer = await customerDatabase.getCurrentCustomer();
      if (customer == null) {
        print('User tidak ditemukan. Silakan login ulang.');
        setState(() => _isProcessing = false);
        return;
      }

      final isAlreadyPremium = await premiumService.checkIfPremiumActive(
        customer.email,
      );

      print('email ${customer.email} status premium : $isAlreadyPremium');

      if (isAlreadyPremium) {
        print('Anda sudah memiliki akses premium aktif.');
        setState(() => _isProcessing = false);
        return;
      }

      DateTime expiryDate;
      if (_selectedPlan == 'monthly') {
        expiryDate = DateTime.now().add(const Duration(days: 30));
      } else {
        expiryDate = DateTime.now().add(const Duration(days: 365));
      }

      final success = await premiumService.upgradeToPremium(
        customerEmail: customer.email,
        expiryDate: expiryDate,
        paymentMethod: _selectedPaymentMethod,
      );

      if (success) {
        NotificationServices.schedulePremiumReminder(
          customerEmail: customer.email,
          expiryDate: expiryDate,
        );

        _showSuccessDialog();
      } else {
        print('Gagal memproses upgrade. Silakan coba lagi.');
      }
    } catch (e) {
      print('Error during upgrade: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showEnableNotificationSnackBar() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.enableNotificationForPremium),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: l10n.enableNotificationAction,
          textColor: Colors.yellow,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            );
          },
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    final l10n = AppLocalizations.of(context)!;
    final lang = Provider.of<LanguageProvider>(context, listen: false).locale;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.stars, size: 40, color: Colors.pink),
            ),
            SizedBox(height: 16),
            Text(
              l10n.premiumSuccessTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          l10n.premiumSuccessMessage,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          Semantics(
            label: tr('button', 'closeSuccessDialogLabel', lang),
            hint: tr('button', 'closeSuccessDialogHint', lang),
            button: true,
            child: ExcludeSemantics(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  l10n.backToProfile,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethods() {
    final l10n = AppLocalizations.of(context)!;
    final lang = Provider.of<LanguageProvider>(context, listen: false).locale;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.selectPaymentMethod,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  Semantics(
                    label: tr('button', 'closePaymentMethodsLabel', lang),
                    hint: tr('button', 'closePaymentMethodsHint', lang),
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _paymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = _paymentMethods[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 10),
                      color: _selectedPaymentMethod == method['id']
                          ? Colors.pink[50]
                          : Colors.white,
                      child: Semantics(
                        label: tr('listTile', 'paymentMethodLabel', lang),
                        hint: tr('listTile', 'selectPaymentMethodHint', lang),
                        button: true,
                        child: ExcludeSemantics(
                          child: ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: method['color'].withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                method['icon'],
                                color: method['color'],
                              ),
                            ),
                            title: Text(
                              _getPaymentMethodName(method['nameKey'], l10n),
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: _selectedPaymentMethod == method['id']
                                ? Icon(Icons.check_circle, color: Colors.pink)
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedPaymentMethod = method['id'];
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool isPremium = false;
  int PremiumDaysLeft = 0;

  Future<void> isUserPremium() async {
    bool stillPremium = await CustomerDatabase().isUserPremium();
    if (stillPremium) {
      setState(() {
        isPremium = stillPremium;
      });
      print("isPremium : ${isPremium}");
    }
  }

  Future<void> premiumSubscriptionLeft() async {
    int remainingPremiumDays = await PremiumService().premiumDaysLeft();
    setState(() {
      PremiumDaysLeft = remainingPremiumDays;
    });
    print("sisa premium di init : ${PremiumDaysLeft}");
  }

  @override
  void initState() {
    isUserPremium();
    premiumSubscriptionLeft();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Provider.of<LanguageProvider>(context, listen: false).locale;
    final selectedPlan = _plans[_selectedPlan]!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Semantics(
          label: tr('button', 'backButtonLabel', lang),
          hint: tr('button', 'backButtonHint', lang),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.pink),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          l10n.premiumTitle,
          style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan badge
            Container(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.pink[50]!,
                    Colors.pink[100]!.withOpacity(0.5),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(Icons.stars, size: 60, color: Colors.pink),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.premiumProBadge,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    l10n.premiumSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            // Plans Selection
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.selectPlan,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _buildPlanCard(
                        context,
                        'monthly',
                        l10n.monthlyPlan,
                        l10n.monthlyPrice,
                        l10n.flexiblePlan,
                        _selectedPlan == 'monthly',
                      ),
                      SizedBox(width: 10),
                      _buildPlanCard(
                        context,
                        'yearly',
                        l10n.yearlyPlan,
                        l10n.yearlyPrice,
                        l10n.savePercent(_plans['yearly']!['savePercent']),
                        _selectedPlan == 'yearly',
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Price Details
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.totalPayment),
                            Text(
                              l10n.priceFormat(selectedPlan['price']),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.pink,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        if (_selectedPlan == 'yearly')
                          Text(
                            l10n.onlyPerMonth(selectedPlan['pricePerMonth']),
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Features List
                  Text(
                    l10n.premiumFeaturesTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _premiumFeatures.length,
                    itemBuilder: (context, index) {
                      final feature = _premiumFeatures[index];
                      return Card(
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: feature['color'].withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  feature['icon'],
                                  color: feature['color'],
                                  size: 20,
                                ),
                              ),
                              Text(
                                _getFeatureTitle(feature['titleKey'], l10n),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _getFeatureDesc(feature['descKey'], l10n),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 30),

                  // Payment Method
                  Card(
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _paymentMethods
                              .firstWhere(
                                (method) =>
                                    method['id'] == _selectedPaymentMethod,
                              )['color']
                              .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _paymentMethods.firstWhere(
                            (method) => method['id'] == _selectedPaymentMethod,
                          )['icon'],
                          color: _paymentMethods.firstWhere(
                            (method) => method['id'] == _selectedPaymentMethod,
                          )['color'],
                        ),
                      ),
                      title: Text(l10n.paymentMethod),
                      subtitle: Text(
                        _getPaymentMethodName(
                          _paymentMethods.firstWhere(
                            (method) => method['id'] == _selectedPaymentMethod,
                          )['nameKey'],
                          l10n,
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _showPaymentMethods,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Terms
                  Text(
                    l10n.premiumTerms,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: tr('button', 'upgradeNowButtonLabel', lang),
              hint: tr('button', 'upgradeNowButtonHint', lang),
              button: true,
              child: ExcludeSemantics(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: isPremium
                      ? Center(
                          child: Column(
                            children: [
                              Text(l10n.alreadyPremiumUser),
                              Text(l10n.premiumDaysLeft(PremiumDaysLeft)),
                            ],
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _isProcessing ? null : _processUpgrade,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 3,
                          ),
                          child: _isProcessing
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Text(
                                  l10n.upgradeButtonText(selectedPlan['price']),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                ),
              ),
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    String planId,
    String title,
    String price,
    String subtitle,
    bool isSelected,
  ) {
    final lang = Provider.of<LanguageProvider>(context, listen: false).locale;

    return Expanded(
      child: Card(
        color: isSelected ? Colors.pink[50] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? Colors.pink : Colors.transparent,
            width: 2,
          ),
        ),
        child: Semantics(
          label: tr('card', '${planId}PlanLabel', lang),
          hint: tr('card', 'selectPlanHint', lang),
          button: true,
          child: ExcludeSemantics(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  _selectedPlan = planId;
                });
              },
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.pink : Colors.grey[300],
                            border: Border.all(
                              color: isSelected
                                  ? Colors.pink
                                  : const Color.fromARGB(255, 232, 231, 231),
                            ),
                          ),
                          child: isSelected
                              ? Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                        SizedBox(width: 8),
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.pink : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getFeatureTitle(String key, AppLocalizations l10n) {
    switch (key) {
      case 'premiumFeatureNoAds':
        return l10n.premiumFeatureNoAds;
      case 'premiumFeatureBadge':
        return l10n.premiumFeatureBadge;
      case 'premiumFeaturePriority':
        return l10n.premiumFeaturePriority;
      case 'premiumFeatureEarlyAccess':
        return l10n.premiumFeatureEarlyAccess;
      default:
        return '';
    }
  }

  String _getFeatureDesc(String key, AppLocalizations l10n) {
    switch (key) {
      case 'premiumFeatureNoAdsDesc':
        return l10n.premiumFeatureNoAdsDesc;
      case 'premiumFeatureBadgeDesc':
        return l10n.premiumFeatureBadgeDesc;
      case 'premiumFeaturePriorityDesc':
        return l10n.premiumFeaturePriorityDesc;
      case 'premiumFeatureEarlyAccessDesc':
        return l10n.premiumFeatureEarlyAccessDesc;
      default:
        return '';
    }
  }

  String _getPaymentMethodName(String key, AppLocalizations l10n) {
    switch (key) {
      case 'paymentMethodGopay':
        return l10n.paymentMethodGopay;
      case 'paymentMethodOvo':
        return l10n.paymentMethodOvo;
      case 'paymentMethodDana':
        return l10n.paymentMethodDana;
      case 'paymentMethodBankTransfer':
        return l10n.paymentMethodBankTransfer;
      case 'paymentMethodCreditCard':
        return l10n.paymentMethodCreditCard;
      default:
        return key;
    }
  }
}
