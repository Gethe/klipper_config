# Custom Klipper Configuration

This is my custom configuration for the Klipper firmware. It is designed to be
easy to set up, and highly modular.

### :warning: Usage of this config is at your own risk :warning:

This config is tailored to my own printers with the specific idiosyncrasies and
mods they have. As such, it may not work well for other printers without
significant changes.

I also run [Danger Klipper](https://github.com/DangerKlippers/danger-klipper) on
my printers, so there are options here that won't be compatible with mainline
Klipper.


## Details

### Common

All major config files are located in [common](common/). These define the macros,
MCUs, drivers, etc. These are generally self contained and can be thought of as
a parts bin of sorts. Also included here are the most basic moonraker.conf and
printer.cfg files, populated with the options that any printer would need.

Like many generalist configs these days, this one makes significant use of a
`_USER_VARIABLES` macro. The variable.cfg file in this folder provides the
defaults for all defined user vars along with any necessary documentation.

Once installed, these files will be found at `~/printer_data/config/common`.

### Host

In a separate directory, with the same name as your pi's hostname (eg. ruby),
are the files that define a specific printer. This includes another pair of
printer/moonraker files with `[include]`s to the respective files in
[common](common/) for the various hardware that it uses. Also available here is
another variables.cfg for printer specific overrides.

This line can be used to change the hostname if needed.
``` bash
sudo hostnamectl set-hostname $new_hostname
```

Once installed, these files will be found at `~/printer_data/config` as eg.
_ruby.conf, _ruby.cfg, and _variables.cfg

### User

All files in this repo will be symlinked into `~/printer_data/config`, and as
such will not be editable. The only files editable from the Mainsail interface
will be new printer.cfg and moonraker.conf files that are created during
installation. These are created with just an `[include]` to their respective
host files and a boilerplate SAVE_CONFIG section to ensure the command works out
of the box.

The intent is that this is where on-the-fly tweaks happen in order to tune the
printer. Once it settles in, those changes should be moved to the host files in
the repo leaving the editable files mostly empty.


## Installation

You should start with a new installation of [Raspberry Pi OS Lite]. I also
recommend setting up any OS level customizations like wifi, ssh, hostname, etc.,
then making a [backup image] prior to installing this config. This can then be
used to quickly spin up a new printer, or recover an existing one.

When ready, run this script to install the printer config along with all other
required components.

``` bash
wget -O - https://raw.githubusercontent.com/gethe/klipper_config/main/install.sh | bash
```


## Credits

A lot of inspiration outside of my own has gone into this config, and I would be
remiss to not place credit where it is due.

Projects that are explicit dependencies of this config include:

* [kiauh](https://github.com/dw-0/kiauh)
* [klippain-shaketune](https://github.com/Frix-x/klippain-shaketune)
* [Moonraker](https://github.com/Arksine/moonraker)
* [Danger Klipper](https://github.com/DangerKlippers/danger-klipper)
* [Mainsail](https://github.com/mainsail-crew/mainsail)

Many of the scripts, macros, and config files included in this repo are based on
or inspired by work from:

* [RatOS Config](https://github.com/Rat-OS/RatOS-configuration)
* [klippain](https://github.com/Frix-x/klippain)
* [klipper-motd](https://github.com/tomaski/klipper-motd)
* nachoparker - [Customize your MOTD]
* Drachenkatze - [Automating Klipper MCU Updates](https://docs.vorondesign.com/community/howto/drachenkatze/automating_klipper_mcu_updates.html)


[Raspberry Pi OS Lite]: (https://www.raspberrypi.com/software/)
[backup image]: (https://www.tomshardware.com/how-to/back-up-raspberry-pi-as-disk-image)
[Customize your MOTD]: (https://web.archive.org/web/20180729211018/https://ownyourbits.com/2017/04/05/customize-your-motd-login-message-in-debian-and-ubuntu/)
