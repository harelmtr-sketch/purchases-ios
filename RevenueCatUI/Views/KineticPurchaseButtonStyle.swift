// Copyright RevenueCat Inc. All Rights Reserved.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI

/// Kinetic's opt-in UI hook. It changes the purchase button's surface, never its action.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension View {
    /// Apply an app-owned button style to native component purchase buttons only.
    ///
    /// Remote labels, eligibility, layout and purchase handling remain SDK-owned.
    /// The style owns the surface; the root stack's fill, border and shadow are
    /// suppressed so they do not obscure the material. Other components retain
    /// their authored styling. Callers must provide any OS/accessibility fallback.
    func kineticPaywallPurchaseButtonStyle<Style: ButtonStyle>(_ style: Style) -> some View {
        environment(\.kineticPaywallPurchaseButtonStyle, AnyKineticPurchaseButtonStyle(style))
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct AnyKineticPurchaseButtonStyle {
    private let render: (AnyView) -> AnyView

    init<Style: ButtonStyle>(_ style: Style) {
        // Install the actual style through SwiftUI so its DynamicProperty and
        // Environment values (disabled, reduced motion/transparency) are resolved.
        render = { AnyView($0.buttonStyle(style)) }
    }

    func apply<Content: View>(to content: Content) -> some View {
        render(AnyView(content))
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct KineticPurchaseButtonStyleModifier: ViewModifier {
    let style: AnyKineticPurchaseButtonStyle?

    @ViewBuilder func body(content: Content) -> some View {
        if let style {
            style.apply(to: content)
        } else {
            content
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct KineticPurchaseButtonStyleKey: EnvironmentKey {
    static let defaultValue: AnyKineticPurchaseButtonStyle? = nil
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension EnvironmentValues {
    var kineticPaywallPurchaseButtonStyle: AnyKineticPurchaseButtonStyle? {
        get { self[KineticPurchaseButtonStyleKey.self] }
        set { self[KineticPurchaseButtonStyleKey.self] = newValue }
    }
}
