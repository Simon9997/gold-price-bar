import Charts
import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: GoldPriceViewModel

    var body: some View {
        ZStack {
            GoldPriceTheme.canvas.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                header
                quoteRow
                chartPanel

                if let errorMessage = viewModel.errorMessage {
                    errorBanner(errorMessage)
                }
            }
            .padding(24)
        }
        .frame(minWidth: 820, minHeight: 580)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 18) {
            PixelPanel(fill: GoldPriceTheme.surfaceStrong, padding: 16) {
                HStack(alignment: .center, spacing: 12) {
                    PixelCoinGlyph(size: 28)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("国际金价")
                            .font(GoldPriceTheme.font(28, weight: .black))
                            .foregroundStyle(GoldPriceTheme.textPrimary)

                        Text("PIXEL BOARD")
                            .font(GoldPriceTheme.font(11, weight: .bold))
                            .foregroundStyle(GoldPriceTheme.textSecondary)

                        Text("\(viewModel.sourceName) / 1S REFRESH / 4 MIN WINDOW")
                            .font(GoldPriceTheme.font(12, weight: .medium))
                            .foregroundStyle(GoldPriceTheme.textSecondary)
                    }
                }
            }

            PixelPanel(fill: GoldPriceTheme.surface, padding: 12) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("DATA SOURCE")
                        .font(GoldPriceTheme.font(11, weight: .bold))
                        .foregroundStyle(GoldPriceTheme.textSecondary)

                    HStack(spacing: 8) {
                        ForEach(GoldPriceSourcePreference.allCases) { source in
                            Button(source.displayName) {
                                Task {
                                    await viewModel.changeSource(to: source)
                                }
                            }
                            .buttonStyle(PixelToggleButtonStyle(selected: source == viewModel.selectedSource))
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Button("MANUAL REFRESH") {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                    .buttonStyle(PixelButtonStyle(prominent: true))
                }
            }
            .frame(width: 312)
        }
    }

    private var quoteRow: some View {
        HStack(alignment: .top, spacing: 18) {
            quoteBlock(
                title: "USD / OZ",
                value: viewModel.latestPriceText,
                detail: "≈ \(viewModel.latestPerGramText) / G"
            )

            quoteBlock(
                title: "RMB / 克",
                value: viewModel.latestPerGramCNYText,
                detail: "≈ \(viewModel.latestPriceCNYText) / 盎司"
            )
        }
    }

    private var chartPanel: some View {
        PixelPanel(fill: GoldPriceTheme.surface, padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("LAST 4 MIN")
                            .font(GoldPriceTheme.font(16, weight: .black))
                            .foregroundStyle(GoldPriceTheme.textPrimary)

                        Text("KITCO / GOLD API TICK TRACE")
                            .font(GoldPriceTheme.font(11, weight: .bold))
                            .foregroundStyle(GoldPriceTheme.textSecondary)
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        infoTag("SOURCE", viewModel.sourceName)
                        infoTag("UPDATE", viewModel.latestUpdatedText)
                        infoTag("MOVE", viewModel.sessionMove ?? "--")
                    }
                }

                if viewModel.chartHistory.count > 1, let domain = chartDomain {
                    Chart(viewModel.chartHistory) { point in
                        LineMark(
                            x: .value("时间", point.timestamp),
                            y: .value("价格", point.pricePerOunce)
                        )
                        .foregroundStyle(GoldPriceTheme.accentStrong)
                        .lineStyle(.init(lineWidth: 2.4, lineCap: .square, lineJoin: .miter))
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .chartYScale(domain: domain)
                    .chartPlotStyle { plot in
                        plot
                            .background(GoldPriceTheme.surfaceSecondary)
                            .overlay {
                                Rectangle()
                                    .stroke(GoldPriceTheme.border, lineWidth: 2)
                            }
                    }
                    .frame(height: 250)
                } else {
                    PixelPanel(fill: GoldPriceTheme.surfaceSecondary, padding: 16) {
                        Text("SAMPLING PRICE DATA...")
                            .font(GoldPriceTheme.font(13, weight: .bold))
                            .foregroundStyle(GoldPriceTheme.textSecondary)
                            .frame(maxWidth: .infinity, minHeight: 214, alignment: .leading)
                    }
                }
            }
        }
    }

    private func quoteBlock(title: String, value: String, detail: String) -> some View {
        PixelPanel(fill: GoldPriceTheme.surface, padding: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(GoldPriceTheme.font(12, weight: .black))
                    .foregroundStyle(GoldPriceTheme.textSecondary)

                Text(value)
                    .font(GoldPriceTheme.font(38, weight: .black))
                    .foregroundStyle(GoldPriceTheme.textPrimary)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Text(detail)
                    .font(GoldPriceTheme.font(12, weight: .medium))
                    .foregroundStyle(GoldPriceTheme.textSecondary)
            }
        }
    }

    private func infoTag(_ title: String, _ value: String) -> some View {
        PixelPanel(fill: GoldPriceTheme.surfaceSecondary, padding: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(GoldPriceTheme.font(10, weight: .bold))
                    .foregroundStyle(GoldPriceTheme.textSecondary)

                Text(value)
                    .font(GoldPriceTheme.font(11, weight: .bold))
                    .foregroundStyle(GoldPriceTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
    }

    private func errorBanner(_ message: String) -> some View {
        PixelPanel(fill: GoldPriceTheme.negative.opacity(0.18), padding: 12) {
            Text("ERROR / \(message)")
                .font(GoldPriceTheme.font(12, weight: .bold))
                .foregroundStyle(GoldPriceTheme.textPrimary)
        }
    }

    private var chartDomain: ClosedRange<Double>? {
        let values = viewModel.chartHistory.map(\.pricePerOunce)
        guard let minValue = values.min(), let maxValue = values.max() else {
            return nil
        }

        let spread = max(maxValue - minValue, maxValue * 0.0008)
        let padding = spread * 0.22
        return (minValue - padding)...(maxValue + padding)
    }
}
