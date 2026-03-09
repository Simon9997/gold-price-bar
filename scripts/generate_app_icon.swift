import AppKit
import Foundation

let outputDirectory: URL

if CommandLine.arguments.count > 1 {
    outputDirectory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
} else {
    outputDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
}

try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

let iconFiles: [(String, CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024),
]

let gridSize = 16
let outerRadius: Double = 6.25
let innerRadius: Double = 4.95

let rimHighlight = NSColor(calibratedRed: 0.99, green: 0.89, blue: 0.44, alpha: 1)
let rimMid = NSColor(calibratedRed: 0.90, green: 0.72, blue: 0.24, alpha: 1)
let rimShadow = NSColor(calibratedRed: 0.69, green: 0.50, blue: 0.12, alpha: 1)
let fillHighlight = NSColor(calibratedRed: 1.00, green: 0.95, blue: 0.66, alpha: 1)
let fillMid = NSColor(calibratedRed: 0.96, green: 0.82, blue: 0.32, alpha: 1)
let fillShadow = NSColor(calibratedRed: 0.82, green: 0.62, blue: 0.16, alpha: 1)
let innerShadow = NSColor(calibratedRed: 0.74, green: 0.53, blue: 0.14, alpha: 1)
let shadowColor = NSColor(calibratedRed: 0.18, green: 0.14, blue: 0.08, alpha: 0.22)

func colorFor(light: Double, isRim: Bool) -> NSColor {
    if isRim {
        if light > 0.38 { return rimHighlight }
        if light > -0.12 { return rimMid }
        return rimShadow
    }

    if light > 0.38 { return fillHighlight }
    if light > -0.12 { return fillMid }
    return fillShadow
}

func drawPixelRect(x: Int, y: Int, cell: CGFloat, color: NSColor) {
    color.setFill()
    NSRect(
        x: CGFloat(x) * cell,
        y: CGFloat(gridSize - 1 - y) * cell,
        width: cell,
        height: cell
    ).fill()
}

func renderIcon(size: CGFloat, to url: URL) throws {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    guard let context = NSGraphicsContext.current?.cgContext else {
        throw NSError(domain: "PixelCoinIcon", code: 1)
    }

    context.setShouldAntialias(false)
    context.interpolationQuality = .none
    context.clear(CGRect(origin: .zero, size: CGSize(width: size, height: size)))

    let cell = size / CGFloat(gridSize)
    let center = (Double(gridSize - 1) / 2.0, Double(gridSize - 1) / 2.0)

    for y in 0 ..< gridSize {
        for x in 0 ..< gridSize {
            let dx = Double(x) - center.0 - 0.15
            let dy = Double(y) - center.1 + 0.15
            let distance = sqrt(dx * dx + dy * dy)

            if distance <= outerRadius {
                if distance <= outerRadius + 0.45 && distance >= innerRadius - 0.25 {
                    drawPixelRect(x: x + 1, y: y + 1, cell: cell, color: shadowColor)
                }
            }
        }
    }

    for y in 0 ..< gridSize {
        for x in 0 ..< gridSize {
            let dx = Double(x) - center.0
            let dy = Double(y) - center.1
            let distance = sqrt(dx * dx + dy * dy)

            guard distance <= outerRadius else {
                continue
            }

            let isRim = distance >= innerRadius
            let normalized = max(distance, 0.0001)
            let nx = dx / normalized
            let ny = dy / normalized
            let light = (-nx - ny) * 0.5
            let color = colorFor(light: light, isRim: isRim)
            drawPixelRect(x: x, y: y, cell: cell, color: color)
        }
    }

    let innerGlowPixels: [(Int, Int)] = [
        (5, 5), (6, 5), (7, 5),
        (4, 6), (5, 6), (6, 6), (7, 6),
        (4, 7), (5, 7), (6, 7),
        (5, 8), (6, 8),
    ]

    for (x, y) in innerGlowPixels {
        drawPixelRect(x: x, y: y, cell: cell, color: fillHighlight.withAlphaComponent(0.55))
    }

    let innerShadowPixels: [(Int, Int)] = [
        (9, 8), (10, 8),
        (8, 9), (9, 9), (10, 9),
        (8, 10), (9, 10),
    ]

    for (x, y) in innerShadowPixels {
        drawPixelRect(x: x, y: y, cell: cell, color: innerShadow.withAlphaComponent(0.85))
    }

    image.unlockFocus()

    guard
        let tiffData = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiffData),
        let pngData = bitmap.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "PixelCoinIcon", code: 2)
    }

    try pngData.write(to: url)
}

for (filename, size) in iconFiles {
    try renderIcon(size: size, to: outputDirectory.appendingPathComponent(filename))
}
