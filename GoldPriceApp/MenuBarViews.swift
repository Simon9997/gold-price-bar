import Charts
import SwiftUI

struct MenuBarLabelView: View {
    @ObservedObject var viewModel: GoldPriceViewModel

    var body: some View {
        Text(viewModel.menuBarTitle)
            .font(GoldPriceTheme.font(12, weight: .black))
            .foregroundStyle(GoldPriceTheme.textPrimary)
            .monospacedDigit()
    }
}

struct MenuBarPanelView: View {
    @ObservedObject var viewModel: GoldPriceViewModel
    let openDashboard: () -> Void
    let quitApp: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 1) {
                Text("国际金价")
                    .font(GoldPriceTheme.font(15, weight: .black))
                    .foregroundStyle(GoldPriceTheme.textPrimary)

                Text("\(viewModel.sourceName) / LIVE PANEL")
                    .font(GoldPriceTheme.font(10, weight: .bold))
                    .foregroundStyle(GoldPriceTheme.textSecondary)
            }
            .padding(.top, 4)

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

            HStack(alignment: .top, spacing: 10) {
                priceBox(title: "USD / OZ", value: viewModel.latestPriceText)
                priceBox(title: "RMB / 克", value: viewModel.latestPerGramCNYText)
            }

            if viewModel.compactHistory.count > 1, let domain = chartDomain {
                PixelPanel(fill: GoldPriceTheme.surfaceSecondary, padding: 10) {
                    Chart(viewModel.compactHistory) { point in
                        LineMark(
                            x: .value("时间", point.timestamp),
                            y: .value("价格", point.pricePerOunce)
                        )
                        .foregroundStyle(GoldPriceTheme.accentStrong)
                        .lineStyle(.init(lineWidth: 2, lineCap: .square, lineJoin: .miter))
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .chartYScale(domain: domain)
                    .chartPlotStyle { plot in
                        plot.background(GoldPriceTheme.surfaceSecondary)
                    }
                    .frame(height: 84)
                }
            }

            HStack(spacing: 8) {
                if let latestUpdatedText = viewModel.latestUpdatedText {
                    infoChip("UPD \(latestUpdatedText)")
                }
                infoChip(viewModel.sessionMove ?? "--")
            }

            HStack(spacing: 8) {
                Button("详情", action: openDashboard)
                    .buttonStyle(PixelButtonStyle(prominent: true))

                Button("刷新") {
                    Task {
                        await viewModel.refresh()
                    }
                }
                .buttonStyle(PixelButtonStyle())

                Button("退出", action: quitApp)
                    .buttonStyle(PixelButtonStyle())
            }

            if let errorMessage = viewModel.errorMessage {
                PixelPanel(fill: GoldPriceTheme.negative.opacity(0.18), padding: 10) {
                    Text(errorMessage)
                        .font(GoldPriceTheme.font(11, weight: .bold))
                        .foregroundStyle(GoldPriceTheme.textPrimary)
                        .lineLimit(2)
                }
            }
        }
        .padding(14)
        .frame(width: 348, alignment: .leading)
        .background(GoldPriceTheme.canvas)
    }

    private func priceBox(title: String, value: String) -> some View {
        PixelPanel(fill: GoldPriceTheme.surface, padding: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(GoldPriceTheme.font(10, weight: .bold))
                    .foregroundStyle(GoldPriceTheme.textSecondary)

                Text(value)
                    .font(GoldPriceTheme.font(20, weight: .black))
                    .foregroundStyle(GoldPriceTheme.textPrimary)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
        }
    }

    private func infoChip(_ text: String) -> some View {
        PixelPanel(fill: GoldPriceTheme.surfaceSecondary, padding: 8) {
            Text(text)
                .font(GoldPriceTheme.font(10, weight: .bold))
                .foregroundStyle(GoldPriceTheme.textPrimary)
                .lineLimit(1)
        }
    }

    private var chartDomain: ClosedRange<Double>? {
        let values = viewModel.compactHistory.map(\.pricePerOunce)
        guard let minValue = values.min(), let maxValue = values.max() else {
            return nil
        }

        let spread = max(maxValue - minValue, maxValue * 0.0006)
        let padding = spread * 0.22
        return (minValue - padding)...(maxValue + padding)
    }
}
