// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import UIKit

struct LightTheme: Theme {
    var type: ThemeType = .light
    var colors: ThemeColourPalette = LightColourPalette()
}

private struct LightColourPalette: ThemeColourPalette {
    // MARK: - Layers
    var layer1: UIColor = FXColors.LightGrey10
    var layer2: UIColor = FXColors.White
    var layer3: UIColor = FXColors.LightGrey20
    var layer4: UIColor = FXColors.LightGrey30.withAlphaComponent(0.6)
    var layer5: UIColor = FXColors.White
    var layerScrim: UIColor = FXColors.DarkGrey30.withAlphaComponent(0.95)
    var layerGradient: Gradient = Gradient(start: FXColors.Violet70, end: FXColors.Violet40)
    var layerAccentNonOpaque: UIColor = FXColors.Blue50.withAlphaComponent(0.1)
    var layerAccentPrivate: UIColor = FXColors.Purple60
    var layerAccentPrivateNonOpaque: UIColor = FXColors.Purple60.withAlphaComponent(0.1)
    var layerLightGrey30: UIColor = FXColors.LightGrey30

    // MARK: - Actions
    var actionPrimary: UIColor = FXColors.Blue50
    var actionPrimaryHover: UIColor = FXColors.Blue60
    var actionSecondary: UIColor = FXColors.LightGrey30
    var actionSecondaryHover: UIColor = FXColors.LightGrey40
    var formSurfaceOff: UIColor = FXColors.LightGrey30
    var formKnob: UIColor = FXColors.White
    var indicatorActive: UIColor = FXColors.LightGrey50
    var indicatorInactive: UIColor = FXColors.LightGrey30

    // MARK: - Text
    var textPrimary: UIColor = FXColors.DarkGrey90
    var textSecondary: UIColor = FXColors.DarkGrey05
    var textDisabled: UIColor = FXColors.DarkGrey90.withAlphaComponent(0.4)
    var textWarning: UIColor = FXColors.Red70
    var textAccent: UIColor = FXColors.Blue50
    var textOnColor: UIColor = FXColors.LightGrey05
    var textInverted: UIColor = FXColors.LightGrey05

    // MARK: - Icons
    var iconPrimary: UIColor = FXColors.DarkGrey90
    var iconSecondary: UIColor = FXColors.DarkGrey05
    var iconDisabled: UIColor = FXColors.DarkGrey90.withAlphaComponent(0.4)
    var iconAction: UIColor = FXColors.Blue50
    var iconOnColor: UIColor = FXColors.LightGrey05
    var iconWarning: UIColor = FXColors.Red70
    var iconAccentViolet: UIColor = FXColors.Violet60
    var iconAccentBlue: UIColor = FXColors.Blue60
    var iconAccentPink: UIColor = FXColors.Pink60
    var iconAccentGreen: UIColor = FXColors.Green60
    var iconAccentYellow: UIColor = FXColors.Yellow60

    // MARK: - Border
    var borderPrimary: UIColor = FXColors.LightGrey30
    var borderAccent: UIColor = FXColors.Blue50
    var borderAccentNonOpaque: UIColor = FXColors.Blue50.withAlphaComponent(0.1)
    var borderAccentPrivate: UIColor = FXColors.Purple60

    // MARK: - Shadow
    var shadow: UIColor = FXColors.DarkGrey80.withAlphaComponent(0.16)
}
