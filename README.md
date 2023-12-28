# Custom Klipper Configuration

This is my custom configuration for the Klipper firmware. It is designed to be
easy to set up, and highly modular.

## Note

This config is tailored to my own printers and the specific idiosyncrasies and
mods they have. As such, it may not work well for other printers without
significant changes.

This config uses the hosts `hostname` to determine which specific config will be
used. Ensure that this has been properly configured prior to installation.

## Installation

This repo assumes an existing installation of Raspberry Pi OS Lite. To begin,
you can run the script below to install the printer config.

``` bash
wget -O - https://raw.githubusercontent.com/gethe/klipper_config/main/install.sh | bash
```

It will download and install this config and all required components.

## Credits

A lot of inspiration outside of my own has gone into this config, and it would
be remiss of me to not place credit where it is due.

Projects that are used directly by this config include:

* [KIAUH]
* [klippain-shaketune]
* [Moonraker]
* [Danger Klipper]
* [Mainsail]

Many of the scripts, macros, and config files included in this repo are based on
work from:

* [RatOS Config]
* [klippain]
* Drachenkatze - [Automating Klipper MCU Updates](https://docs.vorondesign.com/community/howto/drachenkatze/automating_klipper_mcu_updates.html)

[Danger Klipper]: https://github.com/DangerKlippers/danger-klipper
[Moonraker]: https://github.com/Arksine/moonraker
[Mainsail]: https://github.com/mainsail-crew/mainsail
[klippain]: https://github.com/Frix-x/klippain
[klippain-shaketune]: https://github.com/Frix-x/klippain-shaketune
[KIAUH]: https://github.com/th33xitus/kiauh
[RatOS Config]: https://github.com/Rat-OS/RatOS-configuration
