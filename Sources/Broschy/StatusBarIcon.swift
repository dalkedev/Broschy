import AppKit

enum StatusBarIcon {
    /// A vector template keeps the geometric b sharp at menu-bar scale and lets
    /// macOS choose its color for light, dark, and highlighted appearances.
    static func makeImage() -> NSImage {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { _ in
            NSColor.black.setFill()
            let mark = NSBezierPath()
            mark.move(to: NSPoint(x: 3.5, y: 2))
            mark.line(to: NSPoint(x: 3.5, y: 16))
            mark.line(to: NSPoint(x: 6.5, y: 16))
            mark.line(to: NSPoint(x: 6.5, y: 11.5))
            mark.curve(to: NSPoint(x: 15, y: 7), controlPoint1: NSPoint(x: 11, y: 14), controlPoint2: NSPoint(x: 15, y: 11))
            mark.curve(to: NSPoint(x: 6.5, y: 2.8), controlPoint1: NSPoint(x: 15, y: 2), controlPoint2: NSPoint(x: 10, y: 0))
            mark.line(to: NSPoint(x: 6.5, y: 2))
            mark.close()
            mark.appendOval(in: NSRect(x: 6.4, y: 4.1, width: 5.5, height: 5.5))
            mark.windingRule = .evenOdd
            mark.fill()
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "Broschy"
        return image
    }
}
