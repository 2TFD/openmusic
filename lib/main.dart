import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:openmusic/core/app_router/app_router.dart';
import 'package:openmusic/core/bootstrap/app_bootstrap.dart';
import 'package:openmusic/core/di/bloc_scope.dart';
import 'package:openmusic/core/di/di.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final dir = await getApplicationDocumentsDirectory();

  await configureDependencies(appDir: dir.path);
  await AppBootstrap(getIt).run();

  await EasyLocalization.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ttfd.openmusic.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),

      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocScope(
      child: MaterialApp.router(
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
      ),
    );
  }
}
