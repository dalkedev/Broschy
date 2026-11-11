import AppKit
import SwiftUI

private struct FlowReduceMotionKey: EnvironmentKey { static let defaultValue = false }
private struct FlowReduceTransparencyKey: EnvironmentKey { static let defaultValue = false }
extension EnvironmentValues {
    var flowReduceMotion: Bool {
        get { self[FlowReduceMotionKey.self] }
        set { self[FlowReduceMotionKey.self] = newValue }
    }
    var flowReduceTransparency: Bool {
        get { self[FlowReduceTransparencyKey.self] }
        set { self[FlowReduceTransparencyKey.self] = newValue }
    }
}

enum FlowMotion {
    static let selection = Animation.timingCurve(0.22, 1, 0.36, 1, duration: 0.26)
    static let feedback = Animation.easeOut(duration: 0.14)
}

struct NotchShape: Shape {
    var cornerRadius: CGFloat = 20
    var animatableData: CGFloat {
        get { cornerRadius }
        set { cornerRadius = newValue }
    }
    func path(in rect: CGRect) -> Path {
        let radius = min(cornerRadius, rect.height / 2)
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: .init(x: rect.maxX, y: 0))
        path.addLine(to: .init(x: rect.maxX, y: rect.maxY - radius))
        path.addCurve(to: .init(x: rect.maxX - radius, y: rect.maxY),
                      control1: .init(x: rect.maxX, y: rect.maxY - radius * 0.38),
                      control2: .init(x: rect.maxX - radius * 0.38, y: rect.maxY))
        path.addLine(to: .init(x: radius, y: rect.maxY))
        path.addCurve(to: .init(x: 0, y: rect.maxY - radius),
                      control1: .init(x: radius * 0.38, y: rect.maxY),
                      control2: .init(x: 0, y: rect.maxY - radius * 0.38))
        path.closeSubpath()
        return path
    }
}

struct PanelMaterial: View {
    var body: some View {
        // A solid surface keeps text stable over both bright and dark desktops.
        // It also satisfies Reduce Transparency without a second visual system.
        Ink.surface
    }
}

struct PanelOutline: ViewModifier {
    let radius: CGFloat
    func body(content: Content) -> some View {
        content.overlay(NotchShape(cornerRadius: radius).stroke(Ink.separator, lineWidth: 0.5).allowsHitTesting(false))
    }
}

/// Interior controls share the panel's flat, opaque surface vocabulary.
struct ControlSurface: ViewModifier {
    var radius: CGFloat = 8
    @ViewBuilder func body(content: Content) -> some View {
        content.background(Ink.raised, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

struct FlowButtonStyle: ButtonStyle {
    let primary: Bool
    func makeBody(configuration: Configuration) -> some View {
        FlowButtonSurface(label: configuration.label, pressed: configuration.isPressed, primary: primary)
    }
}

private struct FlowButtonSurface<Label: View>: View {
    let label: Label
    let pressed: Bool
    let primary: Bool
    @State private var hovered = false
    @Environment(\.isEnabled) var enabled
    @Environment(\.flowReduceMotion) var reduceMotion
    var body: some View {
        label
            .foregroundStyle(primary ? Ink.onAction : Ink.text)
            .background(primary ? Ink.action : Ink.selection, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.white.opacity(hovered && enabled ? 0.10 : 0)).allowsHitTesting(false))
            .scaleEffect(reduceMotion ? 1 : (pressed ? 0.98 : 1))
            .opacity(enabled ? 1 : 0.48)
            .animation(reduceMotion ? nil : FlowMotion.feedback, value: pressed)
            .animation(reduceMotion ? nil : FlowMotion.feedback, value: hovered)
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .onHover { hovered = $0 }
    }
}

struct QuietButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        QuietButtonSurface(label: configuration.label, pressed: configuration.isPressed)
    }
}

private struct QuietButtonSurface<Label: View>: View {
    let label: Label
    let pressed: Bool
    @State private var hovered = false
    @Environment(\.isEnabled) var enabled
    @Environment(\.flowReduceMotion) var reduceMotion
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        label
            .background((colorScheme == .dark ? Color.white : Color.black)
                .opacity(enabled ? (pressed ? (colorScheme == .dark ? 0.10 : 0.08) : (hovered ? (colorScheme == .dark ? 0.055 : 0.035) : 0)) : 0),
                in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .scaleEffect(pressed && enabled && !reduceMotion ? 0.94 : 1)
            .opacity(enabled ? 1 : 0.55)
            .animation(reduceMotion ? nil : FlowMotion.feedback, value: hovered)
            .animation(reduceMotion ? nil : FlowMotion.feedback, value: pressed)
            .onHover { hovered = $0 }
    }
}
