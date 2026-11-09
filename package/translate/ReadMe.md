# Translate

## Status

|  Locale  |  Lines  | % Done|
|----------|---------|-------|
| Template |     350 |       |
| ca       | 339/350 |   96% |
| de       | 151/350 |   43% |
| es       | 342/350 |   97% |
| fi       | 258/350 |   73% |
| hu       | 300/350 |   85% |
| nl       | 289/350 |   82% |
| pl       | 268/350 |   76% |
| pt_BR    | 325/350 |   92% |
| ru       | 342/350 |   97% |
| tr       | 325/350 |   92% |
| uk       | 213/350 |   60% |
| vi       | 346/350 |   98% |
| zh       | 346/350 |   98% |
| zh_TW    | 304/350 |   86% |


## New Translations

* Fill out [`template.pot`](template.pot) with your translations then open a [new issue](https://github.com/luisbocanegra/plasma-panel-colorizer/issues/new), name the file `spanish.txt`, attach the txt file to the issue (drag and drop).

Or if you know how to make a pull request

* Copy the `template.pot` file and name it your locale's code (Eg: `en`/`de`/`fr`) with the extension `.po`. Then fill out all the `msgstr ""`.
* Your region's locale code can be found at: https://stackoverflow.com/questions/3191664/list-of-all-locales-and-their-short-codes/28357857#28357857

## Scripts

Zren's `kpac` script can easily run the `gettext` commands for you, parsing the `metadata.json` and filling out any placeholders for you. `kpac` can be [downloaded here](https://github.com/Zren/plasma-applet-lib/blob/master/kpac) and should be placed at `~/Code/plasmoid-widgetname/kpac` to edit translations at `~/Code/plasmoid-widgetname/package/translate/`.


* `python3 ./kpac i18n` will parse the `i18n()` calls in the `*.qml` files and write it to the `template.pot` file. Then it will merge any changes into the `*.po` language files. Then it converts the `*.po` files to it's binary `*.mo` version and move it to `contents/locale/...` which will bundle the translations in the `*.plasmoid` without needing the user to manually install them.
* `python3 ./kpac localetest` will convert the `.po` to the `*.mo` files then run `plasmoidviewer` (part of `plasma-sdk`).

## How it works

Since KDE Frameworks v5.37, translations can be bundled with the zipped `*.plasmoid` file downloaded from the store.

* `xgettext` extracts the messages from the source code into a `template.pot`.
* Translators copy the `template.pot` to `fr.po` to translate the French language.
* When the source code is updated, we use `msgmerge` to update the `fr.po` based on the updated `template.pot`.
* When testing or releasing the widget, we convert the `.po` files to their binary `.mo` form with `msgfmt`.

The binary `.mo` translation files are placed in `package/contents/locale/` so you may want to add `*.mo` to your `.gitignore`.

```
package/contents/locale/fr/LC_MESSAGES/plasma_applet_luisbocanegra.panel.colorizer.mo
```

## Links

* https://develop.kde.org/docs/plasma/widget/translations-i18n/
* https://l10n.kde.org/stats/gui/trunk-kf5/team/fr/plasma-desktop/
* https://techbase.kde.org/Development/Tutorials/Localization/i18n_Build_Systems
* https://api.kde.org/frameworks/ki18n/html/prg_guide.html

> Version 8 of [Zren's i18n scripts](https://github.com/Zren/plasma-applet-lib).
