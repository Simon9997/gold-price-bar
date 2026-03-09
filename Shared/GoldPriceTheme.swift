import SwiftUI

enum GoldPriceTheme {
    static let canvas = Color(red: 0.97, green: 0.94, blue: 0.82)
    static let surface = Color(red: 0.99, green: 0.97, blue: 0.90)
    static let surfaceSecondary = Color(red: 0.93, green: 0.88, blue: 0.72)
    static let surfaceStrong = Color(red: 0.88, green: 0.77, blue: 0.47)
    static let border = Color(red: 0.22, green: 0.16, blue: 0.08)
    static let accent = Color(red: 0.83, green: 0.64, blue: 0.18)
    static let accentSoft = Color(red: 0.95, green: 0.86, blue: 0.48)
    static let accentMuted = Color(red: 0.85, green: 0.76, blue: 0.46)
    static let accentStrong = Color(red: 0.63, green: 0.45, blue: 0.10)
    static let textPrimary = Color(red: 0.16, green: 0.11, blue: 0.05)
    static let textSecondary = Color(red: 0.39, green: 0.30, blue: 0.17)
    static let positive = Color(red: 0.24, green: 0.47, blue: 0.21)
    static let negative = Color(red: 0.71, green: 0.28, blue: 0.18)
    static let chartGrid = Color(red: 0.77, green: 0.68, blue: 0.42)

    static func font(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

struct PixelPanel<Content: View>: View {
    let fill: Color
    let padding: CGFloat
    private let content: Content

    init(
        fill: Color = GoldPriceTheme.surface,
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.fill = fill
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(fill)
            .overlay {
                Rectangle()
                    .stroke(GoldPriceTheme.border, lineWidth: 2)
            }
    }
}

struct PixelButtonStyle: ButtonStyle {
    let prominent: Bool

    init(prominent: Bool = false) {
        self.prominent = prominent
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(GoldPriceTheme.font(12, weight: .bold))
            .foregroundStyle(GoldPriceTheme.textPrimary)
            .padding(.horizontal, 12)
            .frame(minHeight: 32)
            .background(configuration.isPressed ? pressedFill : fill)
            .overlay {
                Rectangle()
                    .stroke(GoldPriceTheme.border, lineWidth: 2)
            }
            .opacity(configuration.isPressed ? 0.88 : 1.0)
    }

    private var fill: Color {
        prominent ? GoldPriceTheme.surfaceStrong : GoldPriceTheme.surfaceSecondary
    }

    private var pressedFill: Color {
        prominent ? GoldPriceTheme.accent : GoldPriceTheme.accentMuted
    }
}

struct PixelToggleButtonStyle: ButtonStyle {
    let selected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(GoldPriceTheme.font(11, weight: .bold))
            .foregroundStyle(GoldPriceTheme.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 30)
            .background(fill(isPressed: configuration.isPressed))
            .overlay {
                Rectangle()
                    .stroke(GoldPriceTheme.border, lineWidth: 2)
            }
            .opacity(configuration.isPressed ? 0.88 : 1.0)
    }

    private func fill(isPressed: Bool) -> Color {
        if isPressed {
            return GoldPriceTheme.accentSoft
        }

        return selected ? GoldPriceTheme.surfaceStrong : GoldPriceTheme.surface
    }
}

struct PixelCoinGlyph: View {
    let size: CGFloat

    private let gridSize = 10
    private let rimLight = Color(red: 0.99, green: 0.91, blue: 0.54)
    private let rimMid = Color(red: 0.91, green: 0.73, blue: 0.25)
    private let rimDark = Color(red: 0.70, green: 0.51, blue: 0.13)
    private let coreLight = Color(red: 1.00, green: 0.95, blue: 0.68)
    private let coreMid = Color(red: 0.98, green: 0.83, blue: 0.35)
    private let coreDark = Color(red: 0.83, green: 0.63, blue: 0.18)
    private let borderPixels: Set<String> = [
        "2,0", "3,0", "4,0", "5,0", "6,0", "7,0",
        "1,1", "8,1",
        "0,2", "9,2",
        "0,3", "9,3",
        "0,4", "9,4",
        "0,5", "9,5",
        "0,6", "9,6",
        "0,7", "9,7",
        "1,8", "8,8",
        "2,9", "3,9", "4,9", "5,9", "6,9", "7,9",
    ]
    private let highlightPixels: Set<String> = [
        "2,2", "3,2", "4,2",
        "1,3", "2,3", "3,3",
        "1,4", "2,4",
        "1,5", "2,5",
    ]
    private let darkPixels: Set<String> = [
        "7,4", "8,4",
        "7,5", "8,5",
        "6,6", "7,6", "8,6",
        "5,7", "6,7", "7,7",
    ]
    private let centerMarkPixels: Set<String> = [
        "4,3", "5,3",
        "3,4", "4,4", "5,4",
        "3,5", "4,5",
    ]

    var body: some View {
        let cell = size / CGFloat(gridSize)

        ZStack(alignment: .topLeading) {
            ForEach(0 ..< gridSize * gridSize, id: \.self) { index in
                let x = index % gridSize
                let y = index / gridSize

                if let color = coinColor(x: x, y: y) {
                    pixel(color: color, cell: cell, x: x, y: y)
                }
            }
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private func pixel(color: Color, cell: CGFloat, x: Int, y: Int) -> some View {
        if x >= 0, x < gridSize, y >= 0, y < gridSize {
            Rectangle()
                .fill(color)
                .frame(width: ceil(cell), height: ceil(cell))
                .offset(x: CGFloat(x) * cell, y: CGFloat(y) * cell)
        }
    }

    private func coinColor(x: Int, y: Int) -> Color? {
        let key = "\(x),\(y)"
        let isInterior = (1 ... 8).contains(x) && (1 ... 8).contains(y)
        guard borderPixels.contains(key) || isInterior else {
            return nil
        }

        if borderPixels.contains(key) {
            if y <= 2 || x <= 1 {
                return rimLight
            }
            if y >= 8 || x >= 8 {
                return rimDark
            }
            return rimMid
        }

        if centerMarkPixels.contains(key) {
            return coreLight
        }
        if highlightPixels.contains(key) {
            return coreLight
        }
        if darkPixels.contains(key) {
            return coreDark
        }
        if y <= 3 || x <= 3 {
            return coreLight
        }
        if y >= 7 || x >= 7 {
            return coreDark
        }
        return coreMid
    }
}
