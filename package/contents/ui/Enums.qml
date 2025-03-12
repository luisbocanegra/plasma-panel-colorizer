import QtQuick

Item {

    enum ItemType {
        WidgetItem,
        TrayItem,
        TrayArrow,
        PanelBgItem
    }

    enum ThemeFormColors {
        TextColor,
        DisabledTextColor,
        HighlightedTextColor,
        ActiveTextColor,
        LinkColor,
        VisitedLinkColor,
        NegativeTextColor,
        NeutralTextColor,
        PositiveTextColor,
        BackgroundColor,
        HighlightColor,
        ActiveBackgroundColor,
        LinkBackgroundColor,
        VisitedLinkBackgroundColor,
        NegativeBackgroundColor,
        NeutralBackgroundColor,
        PositiveBackgroundColor,
        AlternateBackgroundColor,
        FocusColor,
        HoverColor
    }

    enum ThemeScopes {
        View,
        Window,
        Button,
        Selection,
        Tooltip,
        Complementary,
        Header
    }

    enum ColorSourceType {
        Custom,
        System,
        CustomList,
        Random,
        Follow
    }
}
