import 'package:flutter/material.dart';
import 'package:mc_reaper_sound/logic/project_provider.dart';
import 'package:mc_reaper_sound/logic/sound_provider.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SoundProvider provider = context.watch<SoundProvider>();
    return Scaffold(
        body: Column(children: [
      if (provider.initialized)
        Expanded(
          child: Builder(builder: (context) {
            var sounds = provider.sounds;
            return ListView(
              children: sounds
                  .map((e) => ListTile(
                        title: Text(e.path),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                context
                                    .read<ProjectProvider>()
                                    .createProject(e);
                                context
                                    .read<ProjectProvider>()
                                    .openProject(e);
                              },
                              icon: const Icon(Icons.add),
                            ),
                            IconButton(
                              onPressed: () {
                                context
                                    .read<ProjectProvider>()
                                    .openProject(e);
                              },
                              icon: const Icon(Icons.play_arrow),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            );
          }),
        ),
    ]));
  }
}
