# Custom Klipper Configuration

This is my custom configuration for the Klipper firmware. It is designed to be
easy to set up, and highly modular.

## Note

This config is tailored to my own printers and the specific idiosyncrasies and
mods they have. As such, it may not work well for other printers without
significant changes.

## Installation

This repo assumes an installation of Raspberry Pi OS Lite (32bit). Once
installed, make sure you have git installed:

``` bash
sudo apt-get update && sudo apt-get install git -y
```
You can then clone the config and run the install script below to install the printer config.

```bash
cd ~ && git clone git@github.com:Gethe/klipper_config.git custom_config
chmod +x ./custom_config/install.sh && ./custom_config/install.sh
```

This will install [KIAUH], through which [Danger Klipper], [Moonraker], and
[Mainsail] will be installed. When that is finished, the config files in this
repo will be symlinked to the correct places. The script will use the Pi's
hostname to determine which specific config will be used.

## Credits

A lot of inspiration outside of my own has gone into this config, and it would
be remiss of me to not place credit where it is due.

[RatOS Config]
[klippain]
[KIAUH]
Drachenkatze - [Automating Klipper MCU Updates](https://docs.vorondesign.com/community/howto/drachenkatze/automating_klipper_mcu_updates.html)

[Danger Klipper]: https://github.com/DangerKlippers/danger-klipper
[Moonraker]: https://github.com/Arksine/moonraker
[Mainsail]: https://github.com/mainsail-crew/mainsail
[klippain]: https://github.com/Frix-x/klippain
[KIAUH]: https://github.com/th33xitus/kiauh
[RatOS Config]: https://github.com/Rat-OS/RatOS-configuration
