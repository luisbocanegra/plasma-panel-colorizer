import QtQuick

Item {
    id: scheme

    property string fgContrast
    property string fgWithAlpha
    property string opacityComponent: "FF"
    property string text: `[General]
ColorScheme=PanelColorizer
Name=Panel colorizer for Window Buttons (${plasmoid.id})
shadeSortColumn=true

[ColorEffects:Disabled]
Color=#f7e7fd
ColorAmount=0.55
ColorEffect=1
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=#ebdfea
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=true
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=#ebdfea
BackgroundNormal=#eedaf8
DecorationFocus=#9518c8
DecorationHover=#9518c8
ForegroundActive=#1e1a1e
ForegroundInactive=#7d747d
ForegroundLink=#2980b9
ForegroundNegative=#da4453
ForegroundNeutral=#f67400
ForegroundNormal=#1e1a1e
ForegroundPositive=#27ae60
ForegroundVisited=#9b59b6

[Colors:Complementary]
BackgroundAlternate=#f9f2fc
BackgroundNormal=#f6e5fd
DecorationFocus=#9518c8
DecorationHover=#9518c8
ForegroundActive=#332f33
ForegroundInactive=#7d747d
ForegroundLink=#2980b9
ForegroundNegative=#ba1b1b
ForegroundNeutral=#f67400
ForegroundNormal=#4c444d
ForegroundPositive=#27ae60
ForegroundVisited=#9b59b6

[Colors:Header]
BackgroundAlternate=#f9f2fc
BackgroundNormal=#f6e5fd
DecorationFocus=#9518c8
DecorationHover=#9518c8
ForegroundActive=#332f33
ForegroundInactive=#7d747d
ForegroundLink=#2980b9
ForegroundNegative=#ba1b1b
ForegroundNeutral=#f67400
ForegroundNormal=#4c444d
ForegroundPositive=#27ae60
ForegroundVisited=#9b59b6

[Colors:Header][Inactive]
BackgroundAlternate=#f9f2fc
BackgroundNormal=#f6e5fd
DecorationFocus=#9518c8
DecorationHover=#9518c8
ForegroundActive=#332f33
ForegroundInactive=#7d747d
ForegroundLink=#2980b9
ForegroundNegative=#ba1b1b
ForegroundNeutral=#f67400
ForegroundNormal=#4c444d
ForegroundPositive=#27ae60
ForegroundVisited=#9b59b6

[Colors:Selection]
BackgroundAlternate=#9518c8
BackgroundNormal=#9518c8
DecorationFocus=#9518c8
DecorationHover=#9518c8
ForegroundActive=#ffffff
ForegroundInactive=#ffffff
ForegroundLink=#98bedd
ForegroundNegative=#e66e73
ForegroundNeutral=#fb9253
ForegroundNormal=#ffffff
ForegroundPositive=#61be7f
ForegroundVisited=#ae7ac5

[Colors:Tooltip]
BackgroundAlternate=#ebdfea
BackgroundNormal=#f9f2fc
DecorationFocus=#9518c8
DecorationHover=#9518c8
ForegroundActive=#1e1a1e
ForegroundInactive=#7d747d
ForegroundLink=#2980b9
ForegroundNegative=#ba1b1b
ForegroundNeutral=#f67400
ForegroundNormal=#1e1a1e
ForegroundPositive=#27ae60
ForegroundVisited=#9b59b6

[Colors:View]
BackgroundAlternate=#f5e2fd
BackgroundNormal=#f9f2fc
DecorationFocus=#9518c8
DecorationHover=#efd5fb
ForegroundActive=#332f33
ForegroundInactive=#7d747d
ForegroundLink=#2b4a66
ForegroundNegative=#ba1b1b
ForegroundNeutral=#c5611d
ForegroundNormal=#4c444d
ForegroundPositive=#2e8d52
ForegroundVisited=#7f4b94

[Colors:Window]
BackgroundAlternate=#f9f2fc
BackgroundNormal=#f6e5fd
DecorationFocus=#9518c8
DecorationHover=#9518c8
ForegroundActive=#332f33
ForegroundInactive=#7d747d
ForegroundLink=#2980b9
ForegroundNegative=#${opacityComponent}ba1b1b
ForegroundNeutral=#f67400
ForegroundNormal=#4c444d
ForegroundPositive=#27ae60
ForegroundVisited=#9b59b6

[KDE]
contrast=4

[WM]
activeBackground=${fgContrast}
activeBlend=227,229,231
activeForeground=${fgWithAlpha}
inactiveBackground=#fff1dcf4
inactiveBlend=239,240,241
inactiveForeground=#4c444d`
}
