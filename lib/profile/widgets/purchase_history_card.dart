import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/model/purchaseHistoryModel.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/helper/semantics.dart';
import 'package:provider/provider.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';

class PurchaseHistoryCard extends StatelessWidget {
  final PurchaseHistory purchase;
  final Function(PurchaseHistory) onEdit;
  final Function(int, String) onDelete;

  const PurchaseHistoryCard({
    super.key,
    required this.purchase,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context, listen: false).locale;
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
                            onEdit(purchase);
                          } else if (value == 'delete') {
                            onDelete(
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
}
