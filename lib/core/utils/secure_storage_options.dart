import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// macOS: the default data-protection keychain needs the
/// `keychain-access-groups` entitlement, which only exists for builds signed
/// with a team profile; without it every write fails with `-34018`. The
/// regular (login) keychain works inside the app sandbox with no entitlement.
/// Other platforms ignore this.
const macOsKeychainOptions = MacOsOptions(useDataProtectionKeyChain: false);
