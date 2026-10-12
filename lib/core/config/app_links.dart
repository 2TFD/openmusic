import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Public OwlSonic website pages linked from the app. They open in the
/// browser and never require signing in.
///
/// These are the planned website routes; the pages themselves (and their
/// legal text) are maintained outside this repository.
abstract final class AppLinks {
  static final privacy = Uri.parse('https://owlsonic.stream/privacy');
  static final terms = Uri.parse('https://owlsonic.stream/terms');
  static final accountDeletion = Uri.parse(
    'https://owlsonic.stream/account-deletion',
  );
  static final support = Uri.parse('https://owlsonic.stream/support');

  /// Opens [uri] outside the app. Replaceable in tests.
  @visibleForTesting
  static Future<bool> Function(Uri uri) opener = _launch;

  static Future<bool> open(Uri uri) async {
    try {
      return await opener(uri);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _launch(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
}
