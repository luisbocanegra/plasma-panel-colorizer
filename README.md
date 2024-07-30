<div align="center">

# Panel Colorizer

[![AUR version](https://img.shields.io/aur/version/plasma6-applets-panel-colorizer?style=for-the-badge&logo=archlinux&labelColor=2d333b&color=1f425f)](https://aur.archlinux.org/packages/plasma6-applets-panel-colorizer)
[![Dynamic JSON Badge](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fluisbocanegra%2Fplasma-panel-colorizer%2Fmain%2Fpackage%2Fmetadata.json&query=KPlugin.Version&style=for-the-badge&color=1f425f&labelColor=2d333b&logo=kde&label=Plasmoid)](https://store.kde.org/p/2130967)
[![Liberapay](https://img.shields.io/liberapay/patrons/luisbocanegra?style=for-the-badge&logo=liberapay&logoColor=%23F6C814&labelColor=%232D333B&label=supporters)](https://liberapay.com/luisbocanegra/)

Fully-featured widget to bring Latte-Dock and WM status bar customization features to the default Plasma panel.

![panel](screenshots/panel.png)

</div>

Inspired by the Latte Dock (now unmaintained) theming and boosted by the laziness to learn editing Plasma themes (which can only change background and other small things) created this project that helps you make the Plasma panels look _almost_ however you want.

## Demo

[![Demo](https://img.shields.io/badge/watch%20on%20youtube-demo?style=for-the-badge&logo=youtube&logoColor=white&labelColor=%23c30000&color=%23222222
)](https://www.youtube.com/watch?v=0QLyEexa9Y4)

<details>
    <summary>Settings</summary>

![tooltip](screenshots/settings.png)

</details>

## Features

### Presets

* Create your own configuration presets
* Restore defaults
* Preset auto-loading
  * Floating panel
  * Maximized window shown

### Widget Background

* Color modes
  * Static
  * Animated
    * Interval
    * Fading
* Colors
  * Custom
  * System
  * Custom list
  * Random
* Contrast correction
* Style
  * Spacing
  * Margin rules
  * Border radius
  * Outline
  * Opacity
  * Shadow
  * Line mode

### Icons and text

* Color Modes
  * Static
  * Interval
  * Follow widget background
* Colors
  * Custom
  * System
  * Custom list
  * Random
  * Contrast correction
* Opacity
* Blacklisted widgets color
* Force icon color to on specific plasmoids that use Kirigami.Icon
* Recolor applications tray icon
* Icons/text shadow

### Panel background

* Opacity
* Color
* Border radius
* Outline
* Constant floating panel side padding
* Shadow
* Remove original panel background

### Other

* Widget Blacklist

## Installing

Install from KDE Store or use `Get new widgets..`

* ~~[Plasma 5](https://store.kde.org/p/2131149) version v0.2.0~~ **[No longer maintained](https://github.com/luisbocanegra/plasma-panel-colorizer/issues/10)**

* [Plasma 6](https://store.kde.org/p/2130967)

### Manually

  1. Install these dependencies or their equivalents for your distribution

      ```txt
      cmake extra-cmake-modules libplasma plasma5support
      ```

  2. Run

      ```sh
      git clone https://github.com/luisbocanegra/plasma-panel-colorizer
      cd plasma-panel-colorizer
      ./install.sh
      ```

### Arch Linux

[aur/plasma6-applets-panel-colorizer](https://aur.archlinux.org/packages/plasma6-applets-panel-colorizer) use your preferred AUR helper e.g:

```sh
yay -S plasma6-applets-panel-colorizer
```

### Nix package

For those using NixOS or the Nix package manager, a Nix package is available in nixpkgs-unstable.

To install the widget use one of these methods:

- NixOS

  ```nix
  environment.systemPackages = with pkgs; [
    plasma-panel-colorizer
  ];
  ```

- [Home-manager](https://github.com/nix-community/home-manager)

  ```nix
  home.packages = with pkgs; [
    plasma-panel-colorizer
  ];
  ```

- [Plasma-manager](https://github.com/nix-community/plasma-manager): If the widget gets added to a panel it will automatically be installed

- Other distros using Nix package manager

  ```
  # without flakes:
  nix-env -iA nixpkgs.plasma-panel-colorizer
  # with flakes:
  nix profile install nixpkgs#plasma-panel-colorizer
  ```

## How to use

1. Put the widget on any of your panels
2. Go to the widget settings to change the current panel appearance (right click > Configure...)
3. Widget can set to only show in panel **Edit Mode** (right click > Hide widget or from the widget settings)

### Restore the original panel appearance

Changes to the panel are not permanent and can be removed by disabling them from **Widget Settings** > **General tab** > **Enabled** checkbox or removing it from the panel and restarting Plasma/logging out.

## Fix Blacklist/Margin/Force recolor not working after updating to version 0.5.0

Since version **0.5.0** partial widget names e.g. _weather_ are no longer allowed. This causes previous rules to stay even after removing the matched widgets.

A button to restore/clear the default rules has been added to the relevant sections.
![image](https://github.com/luisbocanegra/plasma-panel-colorizer/assets/15076387/c94b307b-4c92-49e2-949e-3270e01e3501)

To fix all saved presets a script is provided:

```sh
git clone https://github.com/luisbocanegra/plasma-panel-colorizer
cd plasma-panel-colorizer
./fix-presets-widget-rules.sh
```

The same script can be used to maintain the same widget rules for all presets

## How it works / hacking

This widget works by inject/managing the background and colors of other widgets and the panel where it is placed, the initial goal was to replicate the famous WM status bar look and some Latte Dock theming options without actually modifying the panel/widgets source code.

### Technical

Background is drawn by creating rectangle areas bellow widgets/panel, text and icons repaint is done by editing some elements color property and overwriting `Kirigami.Theme.<something>Color` colors for others, while this works for most widgets, there are some that won't because they draw text and icons differently to what this project matches, if you find a widget that doesn't get colors let me know [here](https://github.com/luisbocanegra/plasma-panel-colorizer/issues/12) and I will try supporting it.

### Performance

Some widgets really like to create/destroy/recolor their own widget elements (e.g. Global Menu), to account for this, text and icons color are re-applied every 250ms. I tried to optimize it so CPU usage only increases around 1-2% on my computer, but usage could vary depending on your System or how many widgets are in your panels.

## Support the development

If you like the project you can:

[!["Buy Me A Coffee"](https://img.shields.io/badge/Buy%20me%20a%20coffe-supporter?logo=buymeacoffee&logoColor=%23282828&labelColor=%23FF803F&color=%23FF803F)](https://www.buymeacoffee.com/luisbocanegra) [![Liberapay](https://img.shields.io/badge/Become%20a%20supporter-supporter?logo=liberapay&logoColor=%23282828&labelColor=%23F6C814&color=%23F6C814)](https://liberapay.com/luisbocanegra/)

Thank you ❤️

## Acknowledgements

* [Search the actual gridLayout of the panel from Plasma panel spacer](https://invent.kde.org/plasma/plasma-workspace/-/blob/Plasma/5.27/applets/panelspacer/package/contents/ui/main.qml?ref_type=heads#L37) code that inspired this project.
* [Google LLC. / Pictogrammers](https://pictogrammers.com/library/mdi/) for the panel icons.
* [sanjay-kr-commit/panelTransparencyToggleForPlasma6](https://github.com/sanjay-kr-commit/panelTransparencyToggleForPlasma6) / [psifidotos/paneltransparencybutton](https://github.com/psifidotos/paneltransparencybutton) for the true panel transparency
