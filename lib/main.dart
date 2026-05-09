import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:terminate_restart/terminate_restart.dart';

import '/ui/home.dart';
import '/utils/get_localization.dart';
import '/utils/update_check_flag_file.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initHive();
  _setAppInitPrefs();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  TerminateRestart.instance.initialize();

  // ❌ TEMP SAFE MODE: all heavy services disabled
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Musify',
      home: const Home(),
      debugShowCheckedModeBanner: false,
      translations: Languages(),
      locale: Locale(
        Hive.box("AppPrefs").get('currentAppLanguageCode') ?? "en",
      ),
      fallbackLocale: const Locale("en"),
      builder: (context, child) {
        final mQuery = MediaQuery.of(context);

        final scale = mQuery.textScaler.clamp(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.1,
        );

        return MediaQuery(
          data: mQuery.copyWith(textScaler: scale),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}

Future<void> initHive() async {
  String path = (await getApplicationDocumentsDirectory()).path;

  await Hive.initFlutter(path);

  await Hive.openBox("SongsCache");
  await Hive.openBox("SongDownloads");
  await Hive.openBox("SongsUrlCache");
  await Hive.openBox("AppPrefs");
}

void _setAppInitPrefs() {
  final appPrefs = Hive.box("AppPrefs");

  if (appPrefs.isEmpty) {
    appPrefs.putAll({
      'themeModeType': 0,
      "cacheSongs": false,
      "skipSilenceEnabled": false,
      'streamingQuality': 1,
      'themePrimaryColor': 4278199603,
      'discoverContentType': "QP",
      'newVersionVisibility': updateCheckFlag,
      "cacheHomeScreenData": true,
    });
  }
}
