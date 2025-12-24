import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/helper/semantics.dart';
import 'package:provider/provider.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';

class InviteFriendsCard extends StatelessWidget {
  final Function(BuildContext) onInvite;

  const InviteFriendsCard({super.key, required this.onInvite});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context, listen: false).locale;
    return Card(
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
              AppLocalizations.of(context)!.inviteFriendsDescription,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.pink),
            onTap: () => onInvite(context),
          ),
        ),
      ),
    );
  }
}
