# Changelog

## [1.1.0](https://github.com/luisbocanegra/plasma-panel-colorizer/compare/v1.0.1...v1.1.0) (2024-11-03)


### Features

* add current version and project urls to header ([ab7fa2c](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/ab7fa2c7934ee7cfaaf29146fc57314513b05d90))
* add filter by active windows for maximized preset auto-loading ([c6dfe49](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/c6dfe4918ade255162bbbfd706eca38f678aa09c))
* allow configuring stock panel settings ([6de0278](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/6de0278901d177c5611e5143664d91503c1e8b35))
* allow disabling preset auto-loading ([20a77d0](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/20a77d042578ce37566c669d752e82e3e1fde069))
* open widget configuration from right click menu on any widget ([e4c88d3](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/e4c88d3ac22ade661ecbe46dfa4ad0d6358a63aa))
* prompt to take preview screenshot after saving preset ([2bfe9c2](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/2bfe9c2109836069c55257da7f84e56b8e9af704))
* reword some settings and update icons ([d5b4057](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/d5b4057e55732775fa8666d8be5551966d14d706))
* show when the C++ plugin is not installed from widget settings ([9a1f7ea](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/9a1f7ea6f9adc9a7e1a511855eb38aebd0b19d64))
* update wording and  use more information messages ([7104389](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/710438998ba992b5b1c119c8dac45097a749eac8))


### Bug Fixes

* allow editing float spinbox manually ([3882199](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/3882199ee6d3c727293c1bf3f9034c27c4346b52))
* allow overriding custom background blur ([04c1bc8](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/04c1bc8c437c260c09265cd40c345f4b11eaf13f))
* disable regular border if custom border is enabled ([21ed741](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/21ed74167eee114f1cc5d47ece8dd6bc8fefb72c))
* native background toggle ([9054b7a](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/9054b7a0730c776925104cf757955649923e1126))
* Non-built-in presets incorrectly marked as built-in ([11f8e91](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/11f8e916d047a68b7afebf426d00b43f00eb2011))
* remove unused panel foreground color ([ec2c56d](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/ec2c56d042d6c8d8c75af7fea5e2ecdf8a502ccc))
* use correct type for default panel opacity ([1aa9029](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/1aa90295dd45e785d9b732de56a7aa978dd6ed2f))

## [1.0.1](https://github.com/luisbocanegra/plasma-panel-colorizer/compare/v1.0.0...v1.0.1) (2024-10-22)


### Bug Fixes

* list presets from separate bash script to avoid default shell limitation ([244ec16](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/244ec1623011c2bf366c88310a784be0b6a46c7b))
* temporary enable panel mask on geometry change to fix broken clickable area ([5b20412](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/5b20412ca2dca07456e763aac622d154524602d9))
* update panel length on startup to fix shrank fit content panel ([91f3fa3](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/91f3fa3249d084a252edb7f02b64dc068c3508b1))

## [1.0.0](https://github.com/luisbocanegra/plasma-panel-colorizer/compare/v0.5.2...v1.0.0) (2024-10-17)


### Features

* add a way to detect existing custom background ([330edb1](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/330edb1f459cd9af5b0fa699c37a4bcd262ddca2))
* add option to toggle debug mode ([5fa12b2](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/5fa12b25c827eb752b917c42a4d4189625f3dfe2))
* Add some more built-in presets ([0dff660](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/0dff660d5c8ab48f0e0ddee623c5c494b6ef7af4)), closes [#54](https://github.com/luisbocanegra/plasma-panel-colorizer/issues/54)
* Allow applying multiple overrides to the same widget ([9e4c466](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/9e4c4661b37c9a4223cb60239e4cb96c39c3f090))
* allow disabling all or specific parts of panel/widget/tray options ([95bba20](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/95bba206ae052803260b3110617163e22a3c913d))
* allow updating forced icon color ([e755a72](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/e755a72575381c82ac28ac5cea345395a003b242))
* automatically unify widgets between start and end ([be7ce3a](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/be7ce3ad96fffa9cd1a1538269880257254d96d1)), closes [#39](https://github.com/luisbocanegra/plasma-panel-colorizer/issues/39)
* bring back force icon color with support for non-symbolic icons ([10af807](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/10af807ce141250d14b671d0068b170bdf1351c2))
* bring back foreground shadow ([3fd7fce](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/3fd7fce9fbbee4371fe017b30352e4e0f2513232)), closes [#69](https://github.com/luisbocanegra/plasma-panel-colorizer/issues/69)
* bring back global disable ([ef0095f](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/ef0095f10f1a346b05ae53f157c6d4a8793b17fd))
* bring back preset autoloading ([383e8fa](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/383e8fab3d7891963dabca515947a132a100dff1))
* bring back widget icon and hide options ([34f8828](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/34f8828dd5670632169918738a113bd6233d4f7d))
* bring back widget/panel custom background blur ([4a5adac](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/4a5adacb229d419eb7651574baaa38a05a7b9ba0)), closes [#72](https://github.com/luisbocanegra/plasma-panel-colorizer/issues/72)
* Built-in presets support ([63a08d3](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/63a08d3dc4110ae4f8146881f5ea018742864670))
* color refresh & expanded representation text color fix ([b11b66c](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/b11b66c84719fdb8506b8781f0dcef71dabfa51f))
* custom widget/panel/tray item margin ([7b2d316](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/7b2d31644f45c33fdeb1c65a52f86512a51d5e81))
* expose the control of native panel visibility/opacity ([2ba52bd](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/2ba52bdc0eb7844b12225b1e1b1baebd82dcee30))
* Fallback to global configuration for disabled override options ([6a2ede1](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/6a2ede1c452d970580721e2fc15cdb6ed58df9d5)), closes [#70](https://github.com/luisbocanegra/plasma-panel-colorizer/issues/70)
* find custom panel background and proper panel fixed side margins ([663dcea](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/663dcea700c6a6099c06a3a0ff4e8a7ef22547ac))
* follow the background color of parent elements ([cf38921](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/cf38921c58761f588e6ac2da66c73c5ab981fcf0))
* hide color animation controls for now ([7306d3a](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/7306d3a5d1824f5b6281a225e72ef0a5104597c8))
* improve settings UI/UX ([a2f3e49](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/a2f3e49a233c350bcde23c91e6306e723da8796e))
* keep track of widgets in panel and system tray ([a6d444f](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/a6d444f1929633f643701118d5eb310e05bad792))
* make widget visible by default ([b1df52b](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/b1df52b324c9cdd7dbb3131437e8f6502447c936))
* panel transparency and opacity ([32ac70b](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/32ac70b5663afc1a16da28aef6b4b75b3799d608))
* per corner radius for background blur mask ([589629c](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/589629ce8e84768c94b11e1a1a4aa194d4d24a82))
* per widget blur override ([fc9e2a2](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/fc9e2a226d6b6d87119f428c0638a2eaef4da0ba))
* per widget configuration override ([8d582c1](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/8d582c10c2f46f14e66077d8b9ccac4c8d8cc49f))
* prepare for per-widget configuration ([6b9b554](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/6b9b5546d7de7ab31ad048921aa93a4bf38ae571))
* presets revamp ([afd4ca8](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/afd4ca8b25941540c12b3f1ce26f9ad1b813ae0e))
* restore appearance when disabling panel/widget/tray tabs ([4a4c298](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/4a4c29816a8925c154c8ed12bfb89096245d6c34))
* spacing between widgets and padding around them ([433ae8d](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/433ae8d2bb060f41f2ac22df1500b300bde49460))
* split overrides and force icon/text color from presets ([c2fe8f8](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/c2fe8f8447a8259557bd52b3dcb7fc41d76c1f35))
* take colors from custom color list ([8a0a4c3](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/8a0a4c36c74b278d9fca5f3f4b687792aa6a2168))
* unified background areas ([ba5ed59](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/ba5ed59bee859acbfa1847da19d112f372ee54f4))
* Update unified background settings labels ([d5ddbce](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/d5ddbce615756465f182726f0c2977e517fc45e1))
* use common components for background ([a3a8ab4](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/a3a8ab416ce00d477ff463df0476557981f855c0))
* User and per preset overrides ([a4ea938](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/a4ea938ce41777c4d8e5adc51bc2925d79d06e73))
* wire colors from system color scheme logic & other stuff ([1f74dd6](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/1f74dd61919e04394c369caaf0db0c3f9db73927))


### Bug Fixes

* actually restore tray color and panel margin on disable ([801ec94](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/801ec94345a547962ae11a7cd097bf1cb03e9c51))
* address multiple colorization issues ([55ae582](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/55ae582d3440371fbb21087284394ead8add4b94)), closes [#55](https://github.com/luisbocanegra/plasma-panel-colorizer/issues/55)
* align blur for top/left of screen, handle widget visibility changes ([22c18cb](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/22c18cb76d95182bb4058c9309dd6efe6ea716ba))
* allow configuration override for tray elements ([858af9c](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/858af9cb6c7ed6306219b2bc8c672fbb0970ea8c))
* allow fallback to global settings for shadows ([431b3ac](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/431b3ac3e8ff7a4d452f9ed98d55de46480dac3f))
* color scope switching and stuck panel padding ([c92df5a](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/c92df5a73aa28345a649a623e20edeaa3088cb3f))
* compensate weird margin of tray expand button ([620024f](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/620024f7cf44f1f28f7fbc3c9629288a2eb0002a))
* correct widget margin for vertical panels ([eafb4ec](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/eafb4ec02dc3cac4c08275ed669a4d31c837ffb4))
* enable/disable by clicking on widget ([c26d797](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/c26d797c7bc773ec22adeca3811adb71908ba348))
* fix broken unified background areas and update on visible ([36c4ea3](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/36c4ea334039a321dbea1f38a0e11cb8bb45e4f2))
* Floating input fields not updating correctly ([171f025](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/171f025476279cc7bdd8ebcdbd5cd494798a32c7))
* forgot to push this for preset autoloading ([69275b3](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/69275b3131b74608658072166639f723862f3740))
* keep original size of unified backgrounds to avoid offset in centered widgets ([9c0013d](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/9c0013da97fff612f7ff1b293124d2be960986be))
* list of custom colors not loading ([ec7f68c](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/ec7f68cf60eaf6871eafc28941631e9a132987a5))
* properly update override configuration key name ([dcfed1c](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/dcfed1c2b3be03db954975143cf1382d1aa29296))
* reload settings and selected tab when switching target element ([4b97002](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/4b97002f402ac9da1fe51dbe664f2a9d29bc2ff2))
* restore default spacing in edit mode to stop plasma from freezing ([c25c6c4](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/c25c6c422ecc3b8599f1247df1333bb504f43c09)), closes [#79](https://github.com/luisbocanegra/plasma-panel-colorizer/issues/79)
* restore default widget margin if zero ([5bacb91](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/5bacb9150ab9a4b6d2683da6cbbcfba1c46b663d))
* settings crash due to binding on buttons with custom colors ([3aa8c07](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/3aa8c0782bc419d0a22bd3b27c9a4f2061e644d3))
* take screenshot and reload preview after saving preset ([27da6f7](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/27da6f7d043977f37110c105638b5e9300c70249))
* update mask offset for Plasma 6.2 ([8a30292](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/8a3029270ab2fbca7bc4c9b9b4dcef616cfd2a2d))
* use negative border width when disabled to avoid rendering issue ([911eff7](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/911eff786d51ac7f635ae4789710bcf18117ae61)), closes [#64](https://github.com/luisbocanegra/plasma-panel-colorizer/issues/64)
* workaround korners bug on custom blur mask ([a0986ba](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/a0986ba551c33bf931ecc0ebc845eb7f0bfdda33))


### Miscellaneous Chores

* release 1.0.0 ([cc10ec0](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/cc10ec0f9c484f564aea0d5cfb9047c860d412b0))

## v0.5.2 Bugfix release (mostly)

### Bug fixes

- Fix transparent outline ugliness by drawing it inside background area
- Restore now removes all customization https://github.com/luisbocanegra/plasma-panel-colorizer/issues/36
- Fix panel background color set not saving https://github.com/luisbocanegra/plasma-panel-colorizer/issues/42
- Fix broken system colors when switching color schemes https://github.com/luisbocanegra/plasma-panel-colorizer/issues/41
- Fix blacklisted color
- Fix default appearance restore
- Ignore global enable from presets
- Fix restoring hidden panel after global disable
- Fix blacklisted color
- Remove outline if background is disabled
- Disable/hide controls based on category/global disabled status
- Disable blacklist on global disable
- Fix per widget margins layout & visibility

### Improvements

- Improve preset auto-loading - Allow loading a preset when a window is touching the panel https://github.com/luisbocanegra/plasma-panel-colorizer/issues/44
- Split margin from background and move to separate Layout tab
- **Don't apply any customization by default** https://github.com/luisbocanegra/plasma-panel-colorizer/issues/36

### Other

- Switch to RGBA for background opacity

## v0.5.1 Bugfix release

### Bug fixes

- Added button to restore default block/margin/force recolor rules to fix rules not being deleted even after removing the matched widgets.

    **Only required if you updated or have presets from version 0.4.0 or older**

    Instructions to fix all broken presets have been provided [here](https://github.com/luisbocanegra/plasma-panel-colorizer?tab=readme-ov-file#fix-blacklistmarginforce-recolor-not-working-after-updating-to-version-050)

- Fixed missing color options for panel background

### Other

- Added click support to increase/decrease value in floating text fields

## v0.5.0 Text/icons shadow

### New features

- Configurable icons/text shadow
- Added option to fix custom badges text
- Allow picking any System (Kirigami.Theme) color

### Bug fixes

- Fixed contrast correction for some color modes
- Fixed original panel opacity requiring custom background to work
- Don't remove widget rules when they are not in the panel being configured

### Other

- Only show a single instance of each widget when configuring
- Now available in AUR [plasma6-applets-panel-colorizer](https://aur.archlinux.org/packages/plasma6-applets-panel-colorizer)

## v0.4.0 Preset management & auto-loading

### New features

- Margins control to unify heights & extra margins for widgets
- Contrast correction for all color modes
- New widget background line mode
- Include tray widgets in force icon color
- Preset management
- Support for app tray icon colorization
- Preset auto-loading on floating panel / Maximized window
- System color option for custom color modes
- Spacing control
- Widget background margin

### Bug fixes

- Allow blacklisting the System Tray widget
- Fix unreadable BadgeOverlay
- Fix colors not updating for window buttons widget
- Fix color animation not working sometimes
- Don't rotate colors in static mode

### Other

- Only reload window buttons widget when fg colors change
- Use list of current widgets for blacklist/force/margins
- Show last preset loaded

## v0.3.0 Tons of new features

### New features

- Foreground (text & icons) customization
- Apply fg color to Window Buttons widget
- option to use a fixed custom panel side padding
- Custom panel background color
- Control real panel background opacity
- Option to fully remove panel background
- Add outline and shadow control
- Force Kirigami.Icon color to specific plasmoids using isMask

### Bug fixes

- Listen for widgets added/removed from the panel
- Don't change fg color in tray expanded representation
- Reduce CPU usage only changing fg color for PlasmoidItem children
- Fix notification applet appearing artifact
- Don't change opacity when disabled
- Continue after error caused by panel being edited

### Other

- Split configuration sections into tabs
- Use color picker for color fields
- Add mouse wheel area to floating text fields

## v0.2.0 Hide widget

- Added option to show the widget only when panel is in panel editing mode.
- System tray position was removed since it wasn't working.

## v0.1.0 First public release (beta)

First usable release all features should work but expect some bugs here and there.

Plasma 6 only but may be ported to plasma 5 if there's interest (PRs welcome)
