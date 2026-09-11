import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import 'ui_error.dart';

extension UiErrorLocalization on UiError {
  String localized(BuildContext context) =>
      context.tr(localeKey, namedArgs: namedArgs);
}
