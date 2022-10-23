import 'package:flutter/material.dart';
import 'package:mc_reaper_sound/logic/config_provider.dart';
import 'package:mc_reaper_sound/logic/project_provider.dart';
import 'package:mc_reaper_sound/logic/sound_provider.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SoundProvider provider = context.watch<SoundProvider>();
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    context.read<SoundProvider>().loadSounds();
                    context.read<ConfigProvider>().init();
                  },
                  icon: const Icon(Icons.refresh),
                  splashRadius: 20,
                ),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Search",
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!provider.initialized) const LinearProgressIndicator(),
          if (provider.initialized)
            Expanded(
              child: Builder(builder: (context) {
                var sounds = provider.sounds;
                return ListView(
                  children: sounds.values
                      .map(
                        (sound) => Padding(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                              color: Colors.black26,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (sound.done)
                                            const Icon(Icons.check_box)
                                          else
                                            const Icon(
                                                Icons.check_box_outline_blank),
                                          const SizedBox(width: 10),
                                          Text(sound.id),
                                          if (sound.numbers.isEmpty)
                                            Builder(builder: (context) {
                                              bool ogAvailable =
                                                  sound.ogSounds.contains(null);
                                              bool customAvailable = sound
                                                  .customSounds
                                                  .contains(null);
                                              return Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.play_arrow,
                                                      color: ogAvailable
                                                          ? Colors.green
                                                          : Colors.red,
                                                    ),
                                                    onPressed: ogAvailable
                                                        ? () => provider
                                                            .playOgSound(
                                                                sound, null)
                                                        : null,
                                                    splashRadius: 15,
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.play_arrow,
                                                      color: customAvailable
                                                          ? Colors.green
                                                          : Colors.grey,
                                                    ),
                                                    onPressed: customAvailable
                                                        ? () =>
                                                            provider.playSound(
                                                                sound, null)
                                                        : null,
                                                    splashRadius: 15,
                                                  ),
                                                ],
                                              );
                                            })
                                          else
                                            ...sound.numbers.map((number) =>
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 6),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.black26,
                                                      ),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                        Radius.circular(20),
                                                      ),
                                                    ),
                                                    child: Builder(
                                                        builder: (context) {
                                                      bool ogAvailable = sound
                                                          .ogSounds
                                                          .contains(number);
                                                      bool customAvailable =
                                                          sound.customSounds
                                                              .contains(number);
                                                      return Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        6.0),
                                                            child: Text(number
                                                                .toString()),
                                                          ),
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons.play_arrow,
                                                              color: ogAvailable
                                                                  ? Colors.green
                                                                  : Colors.red,
                                                            ),
                                                            onPressed: ogAvailable
                                                                ? () => provider
                                                                    .playOgSound(
                                                                        sound,
                                                                        number)
                                                                : null,
                                                            splashRadius: 15,
                                                          ),
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons.play_arrow,
                                                              color:
                                                                  customAvailable
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .grey,
                                                            ),
                                                            onPressed: customAvailable
                                                                ? () => provider
                                                                    .playSound(
                                                                        sound,
                                                                        number)
                                                                : null,
                                                            splashRadius: 15,
                                                          ),
                                                        ],
                                                      );
                                                    }),
                                                  ),
                                                )),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          var provider =
                                              context.read<ProjectProvider>();
                                          await provider.createProject(sound);
                                          provider.openProject(sound);
                                        },
                                        icon: const Icon(Icons.add),
                                      ),
                                      if (sound.reaperProjectExists)
                                        IconButton(
                                          onPressed: () {
                                            context
                                                .read<ProjectProvider>()
                                                .openProject(sound);
                                          },
                                          icon: const Icon(Icons.edit),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              }),
            ),
        ],
      ),
    );
  }
}
