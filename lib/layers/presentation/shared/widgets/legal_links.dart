import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:owlsonic/core/config/app_links.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/snackbars/custom_snack_bar.dart';

/// Opens a public website page and tells the user when no browser could.
Future<void> openLegalLink(BuildContext context, Uri uri) async {
  final opened = await AppLinks.open(uri);
  if (!opened && context.mounted) {
    CustomSnackBar.error(
      context,
      context.tr('legal.openFailed', namedArgs: {'url': '$uri'}),
    );
  }
}

/// "Privacy Policy · Terms of Use", shown where people decide whether to use
/// the app or an account. Works signed out.
class LegalLinks extends StatelessWidget {
  const LegalLinks({super.key, this.showAccountDeletion = false});

  /// Also links the account deletion page (Account screen).
  final bool showAccountDeletion;

  @override
  Widget build(BuildContext context) {
    final style = AppText.bodyM.copyWith(
      fontSize: 12,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.textSub,
    );
    Widget link(String key, String label, Uri uri) => InkWell(
      key: ValueKey(key),
      onTap: () => openLegalLink(context, uri),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Text(label, style: style),
      ),
    );
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.s,
      children: [
        link('legal-privacy', context.tr('legal.privacy'), AppLinks.privacy),
        link('legal-terms', context.tr('legal.terms'), AppLinks.terms),
        if (showAccountDeletion)
          link(
            'legal-account-deletion',
            context.tr('legal.accountDeletion'),
            AppLinks.accountDeletion,
          ),
      ],
    );
  }
}
