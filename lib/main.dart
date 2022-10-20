import 'package:flutter/material.dart';
import 'package:mc_reaper_sound/logic/project_provider.dart';
import 'package:mc_reaper_sound/logic/sound_provider.dart';
import 'package:mc_reaper_sound/view/main_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => SoundProvider()..loadSounds(),
        lazy: false,
      ),
      ChangeNotifierProvider(
        create: (context) => ProjectProvider(),
        lazy: false,
      )
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
