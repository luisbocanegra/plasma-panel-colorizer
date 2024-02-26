# Panel Colorizer plasmoid

Powerful fully-featured KDE Plasma panel colorizer for a WM status bar like appearance

This is a plasmoid whose sole purpose is to inject/manage the background of other widgets in the same panel, the goal was to replicate the famous WM status bar look without actually making other widgets or modifying the panel itself.

![tooltip](screenshots/panel.png)

## Demo


https://github.com/luisbocanegra/plasma-panel-colorizer/assets/15076387/ec1148e2-f81e-472e-af58-b16f177d4983

<details>
    <summary>Settings</summary>

![tooltip](screenshots/settings.png)

</details>

## Current & planned features

> [!IMPORTANT]
> List bellow represents the development status of the main branch, to see the current latest release features look at the readme of each tag e.g. [v0.2.0](https://github.com/luisbocanegra/plasma-panel-colorizer/tree/v0.2.0). Additionally, changes are ported to [plasma5](https://github.com/luisbocanegra/plasma-panel-colorizer/tree/plasma5) branch only after a new tag is created and may take some time.

* [x] Widget Background
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
* [x] Foreground (most icons and text)
  * [x] Color
  * [x] Opacity
    * [ ] Force Kirigami.Icon color to specific plasmoids with `isMask`
* [ ] Panel background (over real background)
  * [ ] Opacity
  * [ ] Color
* [x] Widget Blacklist
* [x] Background padding rules
* [x] Handle widgets added/removed form panel
* [x] Panel side padding (force same padding on all sides)

## Installing

* Install from KDE Store or use `Get new widgets..`
  * [Plasma 5 version](https://store.kde.org/p/2131149)
  * [Plasma 6 version](https://store.kde.org/p/2130967)

### Manual install

1. Install these dependencies (please let me know if I missed or added something unnecessary)

    ```txt
    cmake extra-cmake-modules libplasma plasma5support
    ```

2. Run `./install.sh`

## Acknowledgements

* [Search the actual gridLayout of the panel from Plasma panel spacer](https://invent.kde.org/plasma/plasma-workspace/-/blob/Plasma/5.27/applets/panelspacer/package/contents/ui/main.qml?ref_type=heads#L37) code that inspired this project.
* [Google LLC. / Pictogrammers](https://pictogrammers.com/library/mdi/) for the panel icons.
