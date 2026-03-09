import AppKit

let width = 184
let height = 84
let background = NSColor(calibratedRed: 0.97, green: 0.94, blue: 0.82, alpha: 1.0)
let textPrimary = NSColor(calibratedRed: 0.16, green: 0.11, blue: 0.05, alpha: 1.0)
let textSecondary = NSColor(calibratedRed: 0.39, green: 0.30, blue: 0.17, alpha: 1.0)
let rimLight = NSColor(calibratedRed: 0.99, green: 0.91, blue: 0.54, alpha: 1.0)
let rimMid = NSColor(calibratedRed: 0.91, green: 0.73, blue: 0.25, alpha: 1.0)
let rimDark = NSColor(calibratedRed: 0.70, green: 0.51, blue: 0.13, alpha: 1.0)
let coreLight = NSColor(calibratedRed: 1.00, green: 0.95, blue: 0.68, alpha: 1.0)
let coreMid = NSColor(calibratedRed: 0.98, green: 0.83, blue: 0.35, alpha: 1.0)
let coreDark = NSColor(calibratedRed: 0.83, green: 0.63, blue: 0.18, alpha: 1.0)

let filePath = "/Users/simondominic/dev/gold-price/designs/previews/menu_header_preview.png"

func font(size: CGFloat, weight: NSFont.Weight) -> NSFont {
    if let font = NSFont(name: "Hiragino Sans GB", size: size) {
        return font
    }
    return .systemFont(ofSize: size, weight: weight)
}

let image = NSImage(size: NSSize(width: width, height: height))
image.lockFocus()

background.setFill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: width, height: height)).fill()

let titleAttributes: [NSAttributedString.Key: Any] = [
    .font: font(size: 16, weight: .black),
    .foregroundColor: textPrimary,
]

let subtitleAttributes: [NSAttributedString.Key: Any] = [
    .font: font(size: 11, weight: .bold),
    .foregroundColor: textSecondary,
]

let title = NSAttributedString(string: "国际金价", attributes: titleAttributes)
let subtitle = NSAttributedString(string: "Kitco / LIVE PANEL", attributes: subtitleAttributes)

let iconOrigin = NSPoint(x: 14, y: 26)
let titleOrigin = NSPoint(x: 34, y: 42)
let subtitleOrigin = NSPoint(x: 34, y: 25)

let borderPixels: [String: NSColor] = [
    "2,0": rimLight, "3,0": rimLight, "4,0": rimLight, "5,0": rimLight, "6,0": rimLight, "7,0": rimLight,
    "1,1": rimLight, "8,1": rimMid,
    "0,2": rimLight, "9,2": rimMid,
    "0,3": rimLight, "9,3": rimMid,
    "0,4": rimLight, "9,4": rimDark,
    "0,5": rimMid, "9,5": rimDark,
    "0,6": rimMid, "9,6": rimDark,
    "0,7": rimMid, "9,7": rimDark,
    "1,8": rimMid, "8,8": rimDark,
    "2,9": rimMid, "3,9": rimDark, "4,9": rimDark, "5,9": rimDark, "6,9": rimDark, "7,9": rimDark,
]

let highlightPixels: Set<String> = [
    "2,2", "3,2", "4,2",
    "1,3", "2,3", "3,3",
    "1,4", "2,4",
    "1,5", "2,5",
]

let darkPixels: Set<String> = [
    "7,4", "8,4",
    "7,5", "8,5",
    "6,6", "7,6", "8,6",
    "5,7", "6,7", "7,7",
]

let centerMarkPixels: Set<String> = [
    "4,3", "5,3",
    "3,4", "4,4", "5,4",
    "3,5", "4,5",
]

let gridSize = 10
let cell: CGFloat = 1.4

for y in 0 ..< gridSize {
    for x in 0 ..< gridSize {
        let key = "\(x),\(y)"
        let isInterior = (1 ... 8).contains(x) && (1 ... 8).contains(y)
        guard borderPixels[key] != nil || isInterior else {
            continue
        }

        let color: NSColor
        if let border = borderPixels[key] {
            color = border
        } else if centerMarkPixels.contains(key) || highlightPixels.contains(key) {
            color = coreLight
        } else if darkPixels.contains(key) {
            color = coreDark
        } else if y <= 3 || x <= 3 {
            color = coreLight
        } else if y >= 7 || x >= 7 {
            color = coreDark
        } else {
            color = coreMid
        }

        color.setFill()
        let rect = NSRect(
            x: iconOrigin.x + CGFloat(x) * cell,
            y: CGFloat(height) - iconOrigin.y - CGFloat(y + 1) * cell,
            width: ceil(cell),
            height: ceil(cell)
        )
        NSBezierPath(rect: rect).fill()
    }
}

title.draw(at: titleOrigin)
subtitle.draw(at: subtitleOrigin)

image.unlockFocus()

guard
    let tiffData = image.tiffRepresentation,
    let bitmap = NSBitmapImageRep(data: tiffData),
    let pngData = bitmap.representation(using: .png, properties: [:])
else {
    fatalError("Failed to render preview image")
}

try pngData.write(to: URL(fileURLWithPath: filePath))
print(filePath)
