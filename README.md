# Panel Colorizer plasmoid

Powerful fully-featured KDE Plasma panel colorizer for a WM status bar like appearance

This is a plasmoid whose sole purpose is to inject/manage the background of other widgets in the same panel, the goal was to replicate the famous WM status bar look without actually making other widgets or modifying the panel itself.

## Demo

https://github.com/luisbocanegra/plasma-panel-colorizer/assets/15076387/ec1148e2-f81e-472e-af58-b16f177d4983

<details>
    <summary>Settings</summary>

![tooltip](screenshots/settings.png)

</details>

## Requirements

* Plasma 6

## Current & planned features

* [x] Opacity
* [x] Border radius
* [x] Color modes
  * [x] Static
  * [x] Animated
    * [x] Interval
    * [x] Fading
* [x] Colors
  * [x] Single
  * [x] Accent
  * [x] Custom list
  * [x] Random
    * [x] Saturation
    * [x] Lightness
* [x] Blacklist
* [x] Background padding rules
* [ ] Survive edit mode

## Installing

* Install from KDE Store or use `Get new widgets..`
  * [Plasma 5 version](https://store.kde.org/p/2131149)
  * [Plasma 6 version](https://store.kde.org/p/2130967)

### Manual install

1. Install these dependencies (please let me know if I missed or added something unnecessary)

    ```txt
    cmake extra-cmake-modules libplasma
    ```

2. Run `./install.sh`

## Acknowledgement

* [Google LLC. / Pictogrammers](https://pictogrammers.com/library/mdi/) for the panel icons
