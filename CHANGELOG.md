# Changelog

## [3.0.1](https://github.com/luisbocanegra/plasma-panel-colorizer/compare/v3.0.0...v3.0.1) (2025-05-14)


### Bug Fixes

* unified widgets right edge and system tray gaps ([eb9ec0d](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/eb9ec0dada2d2dcd6852da405d92c8f53ad19dfd))

## [3.0.0](https://github.com/luisbocanegra/plasma-panel-colorizer/compare/v2.6.1...v3.0.0) (2025-05-09)


### ⚠ BREAKING CHANGES

* If you have "Active only" enabled in auto-loading tab you will need to enable it again.

### Features

* add option to filter windows per screen and KWin's top window fallback ([f633405](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/f633405da975e338730d9cccdf1282e93ce7d171))
* current activity preset auto-loading condition ([21ed66a](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/21ed66a075883daa1c45abdafc33c5a0a94f062e))
* remove native shadow from built-in presets that don't need it ([e4ec4ae](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/e4ec4aea9e840202d2509b212dea575dc6a31df1))
* set screen of panel ([9950a51](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/9950a51834abc6cc4af9e79539548b0f7943643b))


### Bug Fixes

* update unfied background areas on widgets HiddenStatus ([753fb9f](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/753fb9f6b5fb4d9a26716fdc2e170b2ff8755946))

## [2.6.1](https://github.com/luisbocanegra/plasma-panel-colorizer/compare/v2.6.0...v2.6.1) (2025-05-02)


### Bug Fixes

* creating a new preset may create an empty directory ([9cc5c4c](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/9cc5c4c1254f751dfec35b525e247b34bd075aae))
* creation of more than one panel background ([d005284](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/d0052844e3b7fe03f28db3ae67a6782de060f511))
* set AnimatedImage layer.live on onPlayingChanged ([9dc76be](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/9dc76be5794ec0348dda7c6d3569bb0d92c801f5))
* set AnimatedImage layer.live on onPlayingChanged ([a4ffc64](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/a4ffc64474f5d3353b65b47dda7f64ab353fb10a))

## [2.6.0](https://github.com/luisbocanegra/plasma-panel-colorizer/compare/v2.5.0...v2.6.0) (2025-04-23)


### Features

* add option to use a gradient as background ([b93e0ec](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/b93e0ec643c1ab8290e4521d6234c0e51f0058f2))
* add option to use an image as background ([749ca04](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/749ca04127d800b93b331d03d09c976eea99c0b4))


### Bug Fixes

* config arrays malformed as objects ([7665734](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/7665734272bb9e1dfeca3232765f1d8ba9237445))
* oops Qt.size not Qt.rect smh ([8940d4c](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/8940d4c516028f0752fec6c6f3f75b05daa256b5))
* override configs being converted to array ([f3e72e4](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/f3e72e49aef9c0df43677ccdcb04f0659ea7312d))


### Performance Improvements

* images: async load, sourceSize & remove source on disabled ([e29b4a9](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/e29b4a9d887352b53ecd8d6fc175343e0c701352))

## [2.5.0](https://github.com/luisbocanegra/plasma-panel-colorizer/compare/v2.4.3...v2.5.0) (2025-04-19)


### Features

* allow floating point values in custom borders ([cb54e0e](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/cb54e0e21168671ac1222162ca0bd4dbd6e4b470))


### Bug Fixes

* add lib64 to QML_IMPORT_PATH for distributions that split lib/lib64 ([0cc3157](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/0cc3157f50551997d523dd7967194b61d3953410))
* secondary custom border offset and radius ([2fe96a5](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/2fe96a588c5c274634df189137fc805fd79fa509))
* unified widgets not saving sometimes ([1f8ebf5](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/1f8ebf556ca0ba02926d473e1fe0e22bea6696d8))

## [2.4.3](https://github.com/luisbocanegra/plasma-panel-colorizer/compare/v2.4.2...v2.4.3) (2025-04-15)


### Bug Fixes

* stuck custom blur/contrast region after removing widget ([48c69d7](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/48c69d710cc0373600688b7efa3f13c136a37516))

## [2.4.2](https://github.com/luisbocanegra/plasma-panel-colorizer/compare/v2.4.1...v2.4.2) (2025-04-06)


### Bug Fixes

* broken coloring in Plasma 6.3.4 ([73f69b3](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/73f69b3211b9d9d2e94aae9d49e7b278b244c999))

## [2.4.1](https://github.com/luisbocanegra/plasma-panel-colorizer/compare/v2.4.0...v2.4.1) (2025-03-16)


### Bug Fixes

* revert problematic content clipping to background ([74dedae](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/74dedae28eb67d5211de82686e0a9b19287b0cba))

## [2.4.0](https://github.com/luisbocanegra/plasma-panel-colorizer/compare/v2.3.1...v2.4.0) (2025-03-16)


### Features

* add option to disable native panel background shadow ([444311f](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/444311fc26c04310b065539276f69941d30b0f2c))
* flash small rectangle for foreground color update in debug mode ([216fd13](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/216fd13e2143d85ba2d62f873e3b4116ebd88c8c))
* make custom background clip widget content ([7debc85](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/7debc8515582526875df2fae6e3e9f4a46744a09))


### Bug Fixes

* blur mask sometimes not updating due to very frequent events ([b4ab72d](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/b4ab72dfb30e5c1634a1d460549de87131a0d402))
* borders not merging for unified widgets ([6ca187b](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/6ca187b787edf3323747b021eec55ca3853b0227))
* missing gdbus_get_signal.sh executable permission for manual install.sh ([97259be](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/97259be87028c9a4f5a79f3453e78ec2e5221a07))
* radious gap between primary and secondary border ([9ef81be](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/9ef81be34ac7b2a42ed3d689d89fbd6b79ac31c8))
* widget click popup not loading presets properly ([08134a8](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/08134a8e71ebb57e472d1e66299ca1fadc5dd063))


### Reverts

* "build: change plugin install from system-wide to widget directory" ([6bd8c23](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/6bd8c23ac050d32a1150df727bcfcd26c087b8c0))

## [2.3.1](https://github.com/luisbocanegra/plasma-panel-colorizer/compare/v2.3.0...v2.3.1) (2025-03-07)


### Bug Fixes

* don't leak dbus replies ([f8cb1c1](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/f8cb1c1660798d9df8670a24edc0376d0742c984))


### Miscellaneous Chores

* release 2.3.1 ([4ef9ea2](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/4ef9ea279e39a85546edb881cc0f92d1bc878fdf))

## [2.3.0](https://github.com/luisbocanegra/plasma-panel-colorizer/compare/v2.2.0...v2.3.0) (2025-02-08)


### Features

* secondary border ([27eecdf](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/27eecdfd6e2dfac83a1ce53c952f147e37ddc288))


### Bug Fixes

* update workaround for upstream panel length bug ([84bcb0b](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/84bcb0ba72c06d6f4851a9777f3899f1ff61507a))

## [2.2.0](https://github.com/luisbocanegra/plasma-panel-colorizer/compare/v2.1.0...v2.2.0) (2025-02-01)


### Features

* option to show a grid behind the panel while configuring ([fedefd9](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/fedefd9b7cdd99c407767ed08a18e0102c075471))
* show spinning indicator on the panel being configured ([b4b8ca4](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/b4b8ca474085c871fee0726f408bcabd20ba301b))


### Bug Fixes

* downgrade a bunch error messages ([e8c526a](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/e8c526af3b55e6ad3537b4a3d9f38cf1f1e86cc5))
* fallback to gdbus for plasma 6.1 ([c699660](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/c699660eaff4a6c2f3cd621f8daec5a9844e98d2))
* floating panel auto-loading condition not working after closing a window ([83b2e58](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/83b2e58c10997a924c95a15bb3809bf4c8b7c5e5))
* mask off by a couple of pixels when panel de-floats ([f266ab2](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/f266ab2165642612473d3a71fe0e7951f9c7af96))
* re-apply customization after changing order of widgets ([b61d14e](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/b61d14e8c9a925c20565225832189ed571a2dd40))
* target current panel by id when changing stock panel settings ([7cf87cb](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/7cf87cbca56b283d41a751fa910024828f355f01))
* updatePanelMask QPainter warnings log spam caused by hidden widgets ([fbd55a3](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/fbd55a3d8cf692d1ee2900f448e8bfe227352d8e))
* use old mask offset for plasma 6.1.x or lower ([495578c](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/495578c8e1a3bf7c25fdd7e3acef1381b219f098))
* widget not hiding (main) ([adb3219](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/adb32194b3f0931f3401bef6f4de43753b331e23))
* widget not hiding once again (main) ([19639a3](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/19639a3e4567bd26035e0d0c765893f6cb1ea63f))
* X11 screen flicker and window resizing with panel ([56c2a4a](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/56c2a4ac7a766bc63c3c6f76c45bdebbaa0b13ea))

## [2.1.0](https://github.com/luisbocanegra/plasma-panel-colorizer/compare/v2.0.0...v2.1.0) (2025-01-26)


### Features

* change default spacing to 4 ([03090e8](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/03090e876d14a335d4fe6ce600119c24e0e74f34))
* option to animate propery changes ([7497524](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/7497524a7011c82131f6f7c42dd1c5f3b9879565))
* option to force always floating dialogs ([6f435ae](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/6f435ae9e58c5e1ec8b95cb6a95596f8e99751d8))
* update and add new presets ([b52b82e](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/b52b82e91be6740dadf87e4ad2ac5a8eaf45f814))


### Bug Fixes

* panel opacity sometimes not applying ([c7bae60](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/c7bae60cca7bb72bf6f949f621b2b75610c4ea57))
* update blur mask after changing radius ([b6d505f](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/b6d505fb9292192bd6fb1202786aba7c23510f39))

## [2.0.0](https://github.com/luisbocanegra/plasma-panel-colorizer/compare/v1.2.0...v2.0.0) (2025-01-20)


### ⚠ BREAKING CHANGES

* Force text/icons, Unified background, Preset/global overrides now use id to address multiple instances of the same widget separately and should be reconfigured. Also widget ids are unique per panel so the setting needs to be recreated and mantained per panel

### Features

* "At least one window is shown" preset auto-loading condition ([d930925](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/d9309259b34fd91a5b19abc756168368e380f285))
* "Fullscreen window" preset auto-loading condition ([eba4a14](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/eba4a14364de61f924e05be83773d56f58ed3c94))
* configure action on Panel Colorizer widget click ([b2c4418](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/b2c4418bf82a1585ee47e57191119814a6a78a7e))
* D-Bus method & signal to edit configuration properties ([6bf4814](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/6bf4814becfa6ec8661965e4d499dc766ccd59b5))
* D-Bus signal to apply preset to all Panel Colorizer instances ([be3aba4](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/be3aba43034bc2c962c1e9d06762a89638c5646f))
* don't store text and icons in presets ([69827e7](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/69827e778ec681c20efa398b58114b5c0058760b))
* enable the D-Bus service by default ([7b3c502](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/7b3c50283e50ef94e31e09fae2f9a08070bc7423))
* log errors when loading preset fails ([d97158d](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/d97158da7611a0b9c4eb95991d2120062bae43b9))
* register a D-Bus service per widget to apply presets ([b549534](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/b5495341122b3538c391b6ae5bd4b996973ced8d))
* show/hide panel "AKA toggle panel" ([3f70386](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/3f703869920fac11b8e25feb748166f5bd17dd0c))
* support per widget instance customization ([fc94f22](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/fc94f22eb63791e131a3a023eef4cf0aa8c17fed))


### Bug Fixes

* always apply alpha to avoid inheriting it from parent ([4151f6e](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/4151f6e2d6e354993e2eb277f61b907e4150ec2f))
* color set option not changing colors ([7a527ff](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/7a527ff5ef9dfb8e7da05c2290553aa427514634))
* disable click to edit built-in preset preview ([94a709c](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/94a709cec9660dc6428bb65a645210d90362c2ca))
* don't change the default text/icon color if disabled ([ec3bd10](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/ec3bd105348d0e9d4a0940713351871cdfc9f577))
* foreground color set option not changing colors ([2aee2d2](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/2aee2d28821e2348ae641cfb9d7af81477f05f00))
* keep original color binding if fg color was never changed ([9cca3c7](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/9cca3c70d638bdcae7bfc3016babebb7997e467e))
* new global override format not saving ([cc80c59](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/cc80c593b3c47da2e54311b3d5eb779e8ff82eff))
* overrides not working for plasmoids in system tray ([371eaf4](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/371eaf40d65d900c8092ad285ea5cb9b97fa3257))
* update windows geometry on config changes ([342fa50](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/342fa50aa0f375d0ee601119f42f1e1836dbdada))
* use even spacing to avoid gaps if unified widgets feature is used ([10c3aa4](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/10c3aa4345bcd2f7227db5b8ecd8657a4ada2ea8))

## [1.2.0](https://github.com/luisbocanegra/plasma-panel-colorizer/compare/v1.1.0...v1.2.0) (2024-11-10)


### Features

* reword some settings messages ([57b61ba](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/57b61bacbd378cfe230f5a55197a1dc432aa341f))


### Bug Fixes

* override changes not saving ([7accd75](https://github.com/luisbocanegra/plasma-panel-colorizer/commit/7accd754370a2733c863172fe7d751f04c4f067f))

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
