import 'package:flutter/material.dart';
import 'package:mc_reaper_sound/logic/config_provider.dart';
import 'package:mc_reaper_sound/logic/project_provider.dart';
import 'package:mc_reaper_sound/logic/sound_provider.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SoundProvider provider = context.read<SoundProvider>();
    TextEditingController controller = TextEditingController();
    controller.addListener(() => provider.filter(controller.text));
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Tooltip(
                  message:
                      "Reload UI | Reads Reaper Files, ogg files and Markdown files",
                  child: IconButton(
                    onPressed: () {
                      context
                          .read<SoundProvider>()
                          .loadSounds(provider.currentInputFile);
                      context.read<ConfigProvider>().init();
                    },
                    icon: const Icon(Icons.refresh),
                    splashRadius: 20,
                  ),
                ),
                Tooltip(
                  message: "Export CSV File",
                  child: IconButton(
                    onPressed: () => provider.exportCSV(),
                    icon: const Icon(Icons.import_export),
                    splashRadius: 20,
                  ),
                ),
                Tooltip(
                  message: "STOP | Kill all VLC player instances",
                  child: IconButton(
                    onPressed: () async => provider.killAllRunningInstances(),
                    icon: const Icon(Icons.stop),
                    splashRadius: 20,
                  ),
                ),
                Text(context
                    .select((SoundProvider value) => value.runningSounds)
                    .toString()),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: "Search",
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Builder(
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black87),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: DropdownButton<String>(
                            underline: Container(),
                            value: context.select(
                                (SoundProvider value) => value.currentInputFile),
                            items: [
                              ...context.select(
                                (SoundProvider value) => value.mdFiles
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e.uri.pathSegments.last,
                                        child: Text(e.uri.pathSegments.last),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                            onChanged: (item) => provider.loadSounds(item!),
                          ),
                        ),
                      ),
                    );
                  }
                )
              ],
            ),
          ),
          Builder(
            builder: (context) {
              SoundProvider watchingProvider = context.watch<SoundProvider>();
              if (!watchingProvider.initialized) {
                const LinearProgressIndicator();
              }
              if (watchingProvider.initialized) {
                return Expanded(
                  child: Builder(builder: (context) {
                    var sounds = watchingProvider.filteredSounds;
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
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
                                                const Icon(Icons
                                                    .check_box_outline_blank),
                                              const SizedBox(width: 10),
                                              Text(sound.id),
                                              if (sound.numbers.isEmpty)
                                                Builder(builder: (context) {
                                                  bool ogAvailable = sound
                                                      .ogSounds
                                                      .contains(null);
                                                  bool customAvailable = sound
                                                      .customSounds
                                                      .contains(null);
                                                  return Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.play_arrow,
                                                          color: ogAvailable
                                                              ? Colors.green
                                                              : Colors.red,
                                                        ),
                                                        onPressed: ogAvailable
                                                            ? () =>
                                                                watchingProvider
                                                                    .playOgSound(
                                                                        sound,
                                                                        null)
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
                                                                watchingProvider
                                                                    .playSound(
                                                                        sound,
                                                                        null)
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
                                                              .symmetric(
                                                          horizontal: 6),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color:
                                                                Colors.black26,
                                                          ),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(
                                                            Radius.circular(20),
                                                          ),
                                                        ),
                                                        child: Builder(
                                                            builder: (context) {
                                                          bool ogAvailable =
                                                              sound.ogSounds
                                                                  .contains(
                                                                      number);
                                                          bool customAvailable =
                                                              sound.customSounds
                                                                  .contains(
                                                                      number);
                                                          return Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        6.0),
                                                                child: Text(number
                                                                    .toString()),
                                                              ),
                                                              IconButton(
                                                                icon: Icon(
                                                                  Icons
                                                                      .play_arrow,
                                                                  color: ogAvailable
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .red,
                                                                ),
                                                                onPressed: ogAvailable
                                                                    ? () => watchingProvider
                                                                        .playOgSound(
                                                                            sound,
                                                                            number)
                                                                    : null,
                                                                splashRadius:
                                                                    15,
                                                              ),
                                                              IconButton(
                                                                icon: Icon(
                                                                  Icons
                                                                      .play_arrow,
                                                                  color: customAvailable
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .grey,
                                                                ),
                                                                onPressed: customAvailable
                                                                    ? () => watchingProvider
                                                                        .playSound(
                                                                            sound,
                                                                            number)
                                                                    : null,
                                                                splashRadius:
                                                                    15,
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
                                          if (!sound.reaperProjectExists)
                                            IconButton(
                                              onPressed: () async {
                                                var provider = context
                                                    .read<ProjectProvider>();
                                                await provider
                                                    .createProject(sound);
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
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}
