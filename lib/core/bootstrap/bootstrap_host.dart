import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openmusic/core/bootstrap/app_initializer.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/presentation/models/ui_error.dart';
import 'package:openmusic/layers/presentation/screens/startup_screen.dart';

class BootstrapHost extends StatefulWidget {
  const BootstrapHost({
    super.key,
    required this.initializer,
    required this.appBuilder,
  });

  final AppInitializer initializer;
  final WidgetBuilder appBuilder;

  @override
  State<BootstrapHost> createState() => _BootstrapHostState();
}

class _BootstrapHostState extends State<BootstrapHost> {
  bool _loading = true;
  bool _ready = false;
  UiError? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (!_loading) setState(() => _loading = true);
    try {
      await widget.initializer.initialize();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _ready = true;
        _error = null;
      });
    } catch (error, stackTrace) {
      final phase = widget.initializer.currentPhase?.name ?? 'unknown';
      final uiError = UiError(localeKey: 'errors.startup');
      await AppLogger.captureException(
        error,
        stackTrace,
        operation: 'bootstrap.$phase',
        occurrenceId: uiError.occurrenceId,
        fatal: true,
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = uiError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ru')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: Builder(builder: widget.appBuilder),
      );
    }

    return MaterialApp(
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: _loading
          ? const StartupScreen()
          : _FatalStartupScreen(error: _error!, onRetry: _initialize),
    );
  }
}

class _FatalStartupScreen extends StatelessWidget {
  const _FatalStartupScreen({required this.error, required this.onRetry});

  final UiError error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final copy = _BootstrapCopy.forLocale(
      PlatformDispatcher.instance.locale,
      error.occurrenceId,
    );
    return Scaffold(
      key: const ValueKey('bootstrap-failure'),
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 48,
                ),
                const SizedBox(height: 20),
                Text(copy.title, style: AppText.display3),
                const SizedBox(height: 12),
                Text(
                  copy.description,
                  style: AppText.bodyM,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const ValueKey('bootstrap-retry'),
                  onPressed: onRetry,
                  child: Text(copy.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _BootstrapCopy {
  const _BootstrapCopy(this.title, this.description, this.retry);

  final String title;
  final String description;
  final String retry;

  factory _BootstrapCopy.forLocale(Locale locale, String id) {
    final shortId = id.substring(0, 8);
    if (locale.languageCode == 'ru') {
      return _BootstrapCopy(
        'Не удалось запустить OpenMusic',
        'Проверьте хранилище устройства и попробуйте снова. '
            'Код ошибки: $shortId',
        'Повторить',
      );
    }
    return _BootstrapCopy(
      'OpenMusic could not start',
      'Check the device storage and try again. Error ID: $shortId',
      'Try again',
    );
  }
}
