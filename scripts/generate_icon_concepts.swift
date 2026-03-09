import AppKit
import Foundation

let outputDirectory: URL

if CommandLine.arguments.count > 1 {
    outputDirectory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
} else {
    outputDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
}

try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

let canvasSize: CGFloat = 1024
let bounds = CGRect(origin: .zero, size: CGSize(width: canvasSize, height: canvasSize))

func roundedRect(_ rect: CGRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func makeImage(named name: String, draw: (CGContext) -> Void) throws {
    let image = NSImage(size: NSSize(width: canvasSize, height: canvasSize))
    image.lockFocus()
    guard let context = NSGraphicsContext.current?.cgContext else {
        throw NSError(domain: "IconConcept", code: 1)
    }

    context.setAllowsAntialiasing(true)
    context.setShouldAntialias(true)
    context.clear(bounds)

    draw(context)

    image.unlockFocus()

    guard
        let tiffData = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiffData),
        let pngData = bitmap.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "IconConcept", code: 2)
    }

    try pngData.write(to: outputDirectory.appendingPathComponent(name))
}

func applyShadow(context: CGContext, color: NSColor, blur: CGFloat, x: CGFloat = 0, y: CGFloat = -18) {
    context.setShadow(offset: CGSize(width: x, height: y), blur: blur, color: color.cgColor)
}

func fillLinearGradient(_ gradient: NSGradient, in path: NSBezierPath, angle: CGFloat) {
    gradient.draw(in: path, angle: angle)
}

let transparent = NSColor.clear
let ivoryTop = NSColor(calibratedRed: 0.97, green: 0.95, blue: 0.90, alpha: 1)
let ivoryBottom = NSColor(calibratedRed: 0.89, green: 0.86, blue: 0.79, alpha: 1)
let goldLight = NSColor(calibratedRed: 0.95, green: 0.80, blue: 0.33, alpha: 1)
let goldMid = NSColor(calibratedRed: 0.83, green: 0.66, blue: 0.23, alpha: 1)
let goldDark = NSColor(calibratedRed: 0.63, green: 0.46, blue: 0.12, alpha: 1)
let graphite = NSColor(calibratedRed: 0.18, green: 0.18, blue: 0.19, alpha: 1)
let graphiteSoft = NSColor(calibratedRed: 0.27, green: 0.27, blue: 0.29, alpha: 1)
let cream = NSColor(calibratedRed: 0.99, green: 0.97, blue: 0.93, alpha: 1)
let lineColor = NSColor(calibratedRed: 0.27, green: 0.23, blue: 0.16, alpha: 1)

func drawBaseTile(_ context: CGContext, tintTop: NSColor, tintBottom: NSColor) {
    let tileRect = bounds.insetBy(dx: 88, dy: 88)
    let tilePath = roundedRect(tileRect, radius: 226)

    context.saveGState()
    applyShadow(context: context, color: NSColor.black.withAlphaComponent(0.18), blur: 46, y: -28)
    tintBottom.setFill()
    tilePath.fill()
    context.restoreGState()

    let gradient = NSGradient(colors: [tintTop, tintBottom])!
    fillLinearGradient(gradient, in: tilePath, angle: -90)

    NSColor.white.withAlphaComponent(0.4).setStroke()
    tilePath.lineWidth = 2
    tilePath.stroke()
}

try makeImage(named: "concept_a_bullion.png") { context in
    drawBaseTile(context, tintTop: ivoryTop, tintBottom: ivoryBottom)

    let topGlow = roundedRect(CGRect(x: 160, y: 610, width: 704, height: 180), radius: 92)
    let glowGradient = NSGradient(colors: [
        NSColor.white.withAlphaComponent(0.48),
        transparent,
    ])!
    fillLinearGradient(glowGradient, in: topGlow, angle: -90)

    let barRect = CGRect(x: 202, y: 332, width: 620, height: 240)
    let barPath = roundedRect(barRect, radius: 82)
    context.saveGState()
    applyShadow(context: context, color: goldDark.withAlphaComponent(0.26), blur: 32, y: -18)
    let barGradient = NSGradient(colors: [goldLight, goldMid, goldDark])!
    fillLinearGradient(barGradient, in: barPath, angle: -90)
    context.restoreGState()

    let topFace = NSBezierPath()
    topFace.move(to: CGPoint(x: 280, y: 572))
    topFace.line(to: CGPoint(x: 732, y: 572))
    topFace.line(to: CGPoint(x: 678, y: 648))
    topFace.line(to: CGPoint(x: 332, y: 648))
    topFace.close()
    let topFaceGradient = NSGradient(colors: [goldLight.blended(withFraction: 0.25, of: .white)!, goldMid])!
    fillLinearGradient(topFaceGradient, in: topFace, angle: -90)

    let chart = NSBezierPath()
    chart.lineWidth = 30
    chart.lineCapStyle = .round
    chart.lineJoinStyle = .round
    chart.move(to: CGPoint(x: 292, y: 400))
    chart.line(to: CGPoint(x: 410, y: 462))
    chart.line(to: CGPoint(x: 516, y: 435))
    chart.line(to: CGPoint(x: 646, y: 520))
    lineColor.setStroke()
    chart.stroke()

    for point in [CGPoint(x: 292, y: 400), CGPoint(x: 410, y: 462), CGPoint(x: 516, y: 435), CGPoint(x: 646, y: 520)] {
        let ring = NSBezierPath(ovalIn: CGRect(x: point.x - 28, y: point.y - 28, width: 56, height: 56))
        cream.setFill()
        ring.fill()
        let inner = NSBezierPath(ovalIn: CGRect(x: point.x - 14, y: point.y - 14, width: 28, height: 28))
        goldDark.setFill()
        inner.fill()
    }
}

try makeImage(named: "concept_b_dial.png") { context in
    drawBaseTile(context, tintTop: NSColor(calibratedRed: 0.20, green: 0.20, blue: 0.22, alpha: 1), tintBottom: NSColor(calibratedRed: 0.12, green: 0.12, blue: 0.13, alpha: 1))

    let ringRect = CGRect(x: 198, y: 198, width: 628, height: 628)
    let ringShadow = NSBezierPath(ovalIn: ringRect)
    context.saveGState()
    applyShadow(context: context, color: NSColor.black.withAlphaComponent(0.34), blur: 42, y: -24)
    NSColor.black.withAlphaComponent(0.24).setFill()
    ringShadow.fill()
    context.restoreGState()

    let ring = NSBezierPath(ovalIn: ringRect)
    ring.lineWidth = 62
    let ringGradient = NSGradient(colors: [goldLight, goldMid, goldDark])!
    ringGradient.draw(in: ring, relativeCenterPosition: .zero)

    let innerDisc = NSBezierPath(ovalIn: CGRect(x: 286, y: 286, width: 452, height: 452))
    let discGradient = NSGradient(colors: [graphiteSoft, graphite])!
    fillLinearGradient(discGradient, in: innerDisc, angle: -90)

    let needle = NSBezierPath()
    needle.lineWidth = 26
    needle.lineCapStyle = .round
    needle.move(to: CGPoint(x: 512, y: 512))
    needle.line(to: CGPoint(x: 680, y: 632))
    cream.setStroke()
    needle.stroke()

    let center = NSBezierPath(ovalIn: CGRect(x: 458, y: 458, width: 108, height: 108))
    let centerGradient = NSGradient(colors: [goldLight, goldDark])!
    fillLinearGradient(centerGradient, in: center, angle: -90)

    let accent = roundedRect(CGRect(x: 310, y: 244, width: 404, height: 70), radius: 35)
    let accentGradient = NSGradient(colors: [goldLight.withAlphaComponent(0.95), goldMid.withAlphaComponent(0.85)])!
    fillLinearGradient(accentGradient, in: accent, angle: 0)
}

try makeImage(named: "concept_c_card.png") { context in
    drawBaseTile(context, tintTop: cream, tintBottom: NSColor(calibratedRed: 0.90, green: 0.88, blue: 0.83, alpha: 1))

    let backCardRect = CGRect(x: 212, y: 274, width: 520, height: 420)
    let backCard = roundedRect(backCardRect, radius: 82)
    context.saveGState()
    applyShadow(context: context, color: graphite.withAlphaComponent(0.18), blur: 30, x: -12, y: -8)
    NSColor(calibratedRed: 0.91, green: 0.87, blue: 0.78, alpha: 1).setFill()
    backCard.fill()
    context.restoreGState()

    let frontCardRect = CGRect(x: 292, y: 340, width: 520, height: 420)
    let frontCard = roundedRect(frontCardRect, radius: 86)
    context.saveGState()
    applyShadow(context: context, color: NSColor.black.withAlphaComponent(0.20), blur: 34, y: -18)
    let frontGradient = NSGradient(colors: [NSColor.white, NSColor(calibratedRed: 0.95, green: 0.93, blue: 0.89, alpha: 1)])!
    fillLinearGradient(frontGradient, in: frontCard, angle: -90)
    context.restoreGState()

    let header = roundedRect(CGRect(x: 344, y: 640, width: 416, height: 86), radius: 42)
    let headerGradient = NSGradient(colors: [goldLight, goldMid])!
    fillLinearGradient(headerGradient, in: header, angle: -90)

    graphite.setFill()
    roundedRect(CGRect(x: 362, y: 538, width: 220, height: 34), radius: 17).fill()
    graphite.withAlphaComponent(0.75).setFill()
    roundedRect(CGRect(x: 362, y: 468, width: 150, height: 30), radius: 15).fill()
    graphite.withAlphaComponent(0.75).setFill()
    roundedRect(CGRect(x: 362, y: 400, width: 288, height: 30), radius: 15).fill()

    let line = NSBezierPath()
    line.lineWidth = 28
    line.lineCapStyle = .round
    line.lineJoinStyle = .round
    line.move(to: CGPoint(x: 398, y: 420))
    line.line(to: CGPoint(x: 494, y: 490))
    line.line(to: CGPoint(x: 592, y: 470))
    line.line(to: CGPoint(x: 704, y: 560))
    goldMid.setStroke()
    line.stroke()

    for point in [CGPoint(x: 398, y: 420), CGPoint(x: 494, y: 490), CGPoint(x: 592, y: 470), CGPoint(x: 704, y: 560)] {
        let dot = NSBezierPath(ovalIn: CGRect(x: point.x - 20, y: point.y - 20, width: 40, height: 40))
        goldLight.setFill()
        dot.fill()
    }
}
