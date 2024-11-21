Custom Klipper Configuration
============================

> [!CAUTION]
> This is still very much a work in progress, and has had very little practical
> testing.

This is my custom configuration for the Klipper firmware. It is designed to be
easy to set up, and highly modular. I made this primarily to make it easier to
share macros and other settings between printers, as well as to provide a config
backup in case anything unfortunate happens.

> [!WARNING]
> Usage of this config is at your own risk.
>
> This config is tailored to my own printers with the specific idiosyncrasies
> and mods that they have. One of those is [Danger-Klipper], and there are
> options in use here that won't be compatible with mainline Klipper.

Installation
------------

You should start with a new installation of [Raspberry Pi OS Lite]. I also
recommend setting up any OS level customizations like wifi, ssh, hostname, etc.,
then making a [backup image] prior to installing this config. This can then be
used to quickly spin up a new printer, or recover an existing one.

When ready, run this script to install the printer config along with all other
required components.

``` bash
wget -O - https://raw.githubusercontent.com/gethe/klipper_config/main/install.sh | bash
```

Details
-------

All files in this repo will be symlinked into `~/printer_data/config`. This
means that they will not be editable outside of the repo directory. The intent
is that the "User" files is where on-the-fly tweaks happen in order to tune the
printer. Once things settle in, those changes should be moved to the "Host"
files in the repo leaving the editable files mostly empty.

### User ###

The only files editable from the Mainsail interface will be the printer.cfg and
moonraker.conf files that are created during installation. These are created
with just an `[include]` to their respective host files and a boilerplate
SAVE_CONFIG section to ensure the command works out of the box.

### Host ###

The hosts' `hostname` is used in various ways to define a specific printer, so
it's important to have a unique `hostname` for each printer using this config.

This line can be used to change the hostname if needed.

``` bash
sudo hostnamectl set-hostname $new_hostname
```

In the repo directory, there should be separate directory with the same name as
your pi's hostname (eg. [~/custom_config/ruby](ruby/)). This is where host specific
files are kept including our printer.cfg and moonraker.conf files. Each will
have `[include]`s to their respective "Common" files for the various hardware
and software that it uses. Also here is a variables.cfg for printer specific
variable overrides. These files will be symlinked to `~/printer_data/config` as
eg. _ruby.conf, _ruby.cfg, and _variables.cfg

This is also where the printer specific theme and flashing files will go.

### Common ###

All major config files are located in [~/custom_config/common](common/). These define
the macros, MCUs, drivers, etc. These are generally self contained and can be
thought of as a parts bin of sorts. Also included here are the most basic
moonraker.conf and printer.cfg files, populated with the options that any
printer would need.

Like many generalist configs these days, this one makes significant use of a
`_USER_VARIABLES` macro. The variable.cfg file in this folder provides the
defaults for all defined user vars, along with any necessary documentation.

These files will be symlinked to `~/printer_data/config/common`.

Credits
-------

A lot of inspiration outside of my own has gone into this config, and I would be
remiss to not place credit where it is due.

Projects that are directly installed and used for at least one printer config
include:

* [kiauh](https://github.com/dw-0/kiauh)
* [klippain-shaketune](https://github.com/Frix-x/klippain-shaketune)
* [Moonraker](https://github.com/Arksine/moonraker)
* [Danger-Klipper]
* [KlipperScreen](https://github.com/KlipperScreen/KlipperScreen)
* [Mainsail](https://github.com/mainsail-crew/mainsail)

Many of the scripts, macros, and config files included in this repo are based on
or inspired by work from:

* [RatOS Config](https://github.com/Rat-OS/RatOS-configuration)
* [Ellis' Guide](https://ellis3dp.com/Print-Tuning-Guide/)
* [klippain](https://github.com/Frix-x/klippain)
* [jschuh](https://github.com/jschuh/klipper-macros)
* Drachenkatze - [Automating Klipper MCU Updates](https://docs.vorondesign.com/community/howto/drachenkatze/automating_klipper_mcu_updates.html)

[Danger-Klipper]: https://github.com/DangerKlippers/danger-klipper
[Raspberry Pi OS Lite]: https://www.raspberrypi.com/software/
[backup image]: https://www.tomshardware.com/how-to/back-up-raspberry-pi-as-disk-image/
[Customize your MOTD]: https://web.archive.org/web/20180729211018/https://ownyourbits.com/2017/04/05/customize-your-motd-login-message-in-debian-and-ubuntu/
