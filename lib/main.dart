import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mc_reaper_sound/logic/config_provider.dart';
import 'package:mc_reaper_sound/logic/project_provider.dart';
import 'package:mc_reaper_sound/logic/sound_provider.dart';
import 'package:mc_reaper_sound/view/main_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  ConfigProvider configProvider = ConfigProvider()..init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(
        value: configProvider,
      ),
      ChangeNotifierProvider(
        create: (context) => SoundProvider()..loadSounds("all_sounds.md"),
        lazy: false,
      ),
      ChangeNotifierProvider(
        create: (context) => ProjectProvider(configProvider),
        lazy: false,
      ),
    ],
    child: const MyApp(),
  ));
}

GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: "/",
      name: "home",
      pageBuilder: (context, state) => const MaterialPage(
        child: MainScreen(),
      ),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      debugShowCheckedModeBanner: false,
      title: 'mc-reaper-sound',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
