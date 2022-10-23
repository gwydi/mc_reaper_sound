# mc_reaper_sound

This projects aim is to make the creation of minecraft sound packs using reaper a little easier.

## Installation
Follow these steps if you have not already done so:

- Download the latest build of this project [here](https://github.com/gwydi/mc_reaper_sound/releases)
- Install reaper [here](https://www.reaper.fm/)
- add reaper to the path ([guide on adding to path](https://www.architectryan.com/2018/03/17/add-to-the-path-on-windows-10/))
- download and unzip ffmpeg [here](https://github.com/BtbN/FFmpeg-Builds/releases)
- add ffmpeg to the path
- install vlc [here](https://www.videolan.org/vlc/index.de.html)
- add vlc to the path
- download the original sounds and put them under ```~/.mcspack/.og/``` (the folder should contain ambient, block, damage ...)
- clone the [mc-spack repo](https://github.com/gwydi/hslu-mcspack) into ```~/AppData/Roaming/.minecraft/resourcepacks```
- download [this](https://raw.githubusercontent.com/gwydi/mc_reaper_sound/main/config.json) file and move it to ```~/.mcspack/.og/config.json```
- download [this](https://raw.githubusercontent.com/gwydi/mc_reaper_sound/main/template_project.rpp) file and move it to ```~/.mcspack/.og/template_project.rpp```

## known issues
- reaper files with only one sound inside them have an issue when exporting. The rendered files need to be renamed manually (remove the ```template_project.rpp```)
- the sounds under ```/event/raid/``` and ```/block/bell/bell_use``` do not work because the game has an inconsistent naming convention with those files.
- playing one sound does not stop the previous sound from playing

