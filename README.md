Custom Klipper Configuration
============================

> [!CAUTION]
> This is still very much a work in progress, and has had very little practical
> testing.

This is my custom configuration for the [Kalico] 3D printer firmware. It is
designed to be easy to set up, and highly modular. I made this primarily to make
it easier to share macros and other settings between printers, as well as to
provide a config backup in case anything unfortunate happens.

> [!WARNING]
> Usage of this config is at your own risk.
>
> This config is tailored to my own printers with the specific idiosyncrasies
> that they have. One of those is [Kalico], so there are options and
> features in use here that won't be compatible with mainline Klipper.

Details
-------

This config works by symlinking the config files into `~/printer_data/config`.
Because of this, they will not be editable outside of the repo directory. The
intent is that the "User" files are where on-the-fly tweaks happen in order to
tune the printer. Once things settle in, those changes should be moved to the
"Printer" files in the repo leaving the editable files mostly empty.

### User ###

The only files editable from the web interface will be the printer.cfg and
moonraker.conf files that are created during installation. These are created
with just an `[include]` to their respective "Printer" files and a boilerplate
SAVE_CONFIG section to ensure the command works out of the box.

### Printer ###

The printer name is used in various ways to define a specific printer, so it's
important to have a unique name for each printer using this config. This is
especially important if hosting multiple printers on one device.

In the repo directory, there should be separate directories with unique names
used to identify a printer (eg. [~/klipper_config/printer_ruby](printer_ruby/)
or [~/klipper_config/printer_slate](printer_slate/)). This is where printer
specific files are kept to actually define its hardware capabilities. Each will
have `[include]`s to their respective "Common" files for the various hardware
and software that it uses.

These files will be symlinked to the config folder as eg. _ruby.conf, _ruby.cfg,
and _variables.cfg.

### Common ###

All major config files are located in [~/klipper_config/common](common/). These
define the macros, MCUs, drivers, etc. These are generally self contained and
can be thought of as a parts bin of sorts. Also included here are the most basic
moonraker.conf and printer.cfg files, populated with the options that any
printer would need.

Like many generalist configs these days, this one makes significant use of a
`_USER_VARIABLES` macro. The variable.cfg file in this folder provides the
defaults for all defined user vars, along with any necessary documentation.

Installation
------------

You should start with a new installation of [Raspberry Pi OS Lite]. I also
recommend setting up any OS level customizations like wifi, ssh, hostname, etc.,
then making a [backup image] prior to installing this config. This can then be
used to quickly spin up a new printer, or recover an existing one.

[KIAUH] is recommended to then install [Kalico], [Moonraker], and
[Fluidd], as well as to flash your MCU(s). See [this guide] for more on how to
set up DK in KIAUH.

Before installing the actual config, first [fork this repo] and rename the
folders for my printers (bubbles, ruby, and slate) to match yours. You will want
to customize the files therein of course, but this will get you started. Run the
script below and it will clone the repo and create symlinks for the given
printer's config. Replace `name` with the name of the printer.

``` bash
wget -O - https://raw.githubusercontent.com/gethe/klipper_config/main/install.sh | bash -s name
```

The install script supports multi-instance setups. It will auto detect if the
folder `~/printer_<name>_data` exists and will default to that location instead
of `~/printer_data` as described in [Details](#details). If your printer uses a
different naming scheme, the full path can be supplied as an optional second
parameter to the install script.

Slicer Configuration
--------------------

### PrusaSlicer and derivatives ###

#### Start G-code ####

```gcode
START_PRINT EXTRUDER=[nozzle_temperature_initial_layer] BED=[bed_temperature_initial_layer_single] CHAMBER=[chamber_temperature] MATERIAL=[filament_type]
```

#### End G-code ####

```gcode
END_PRINT
```

#### Before layer change G-code ####

```gcode
BEFORE_LAYER_CHANGE HEIGHT=[layer_z] LAYER=[layer_num]
;[layer_z]
```

#### After layer change G-code ####

```gcode
;[layer_z]
AFTER_LAYER_CHANGE
```

Credits
-------

A lot of inspiration outside of my own has gone into this config, and I would be
remiss to not place credit where it is due.

Projects that this config depends on include:

* [KIAUH]
* [Kalico]
* [Moonraker]
* [Fluidd]

Many of the scripts, macros, and config files included in this repo are based on
or inspired by work from:

* [RatOS Config](https://github.com/Rat-OS/RatOS-configuration)
* [Ellis' Guide](https://ellis3dp.com/Print-Tuning-Guide/)
* [Frix-x/klippain](https://github.com/Frix-x/klippain)
* [jschuh/klipper-macros](https://github.com/jschuh/klipper-macros)
* [tomaski/klipper-motd](https://github.com/tomaski/klipper-motd)
* [bumbeng/Fluidd_theme_simple](https://github.com/bumbeng/Fluidd_theme_simple)
* nachoparker - [Customize your MOTD](https://web.archive.org/web/20180729211018/https://ownyourbits.com/2017/04/05/customize-your-motd-login-message-in-debian-and-ubuntu/)
* Drachenkatze - [Automating Klipper MCU Updates](https://docs.vorondesign.com/community/howto/drachenkatze/automating_klipper_mcu_updates.html)

[KIAUH]: https://github.com/dw-0/kiauh
[Kalico]: https://github.com/KalicoCrew/kalico
[Moonraker]: https://github.com/Arksine/moonraker
[Fluidd]: https://github.com/fluidd-core/fluidd
[Raspberry Pi OS Lite]: https://www.raspberrypi.com/software/
[backup image]: https://www.tomshardware.com/how-to/back-up-raspberry-pi-as-disk-image/
[this guide]: https://docs.kalico.gg/Migrating_from_Klipper.html#option-2-using-kiauh
[fork this repo]: https://github.com/gethe/klipper_config/fork
