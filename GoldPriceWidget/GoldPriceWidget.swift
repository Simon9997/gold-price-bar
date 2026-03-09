import SwiftUI
import WidgetKit

struct GoldPriceEntry: TimelineEntry {
    let date: Date
    let quote: GoldQuote?
    let errorMessage: String?
}

struct GoldPriceTimelineProvider: TimelineProvider {
    private let service = GoldPriceService()

    func placeholder(in context: Context) -> GoldPriceEntry {
        GoldPriceEntry(date: .now, quote: .preview, errorMessage: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (GoldPriceEntry) -> Void) {
        if context.isPreview {
            completion(placeholder(in: context))
            return
        }

        Task {
            completion(await fetchEntry())
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GoldPriceEntry>) -> Void) {
        Task {
            let entry = await fetchEntry()
            let nextRefresh: Date

            if entry.quote != nil {
                nextRefresh = entry.date.addingTimeInterval(15 * 60)
            } else {
                nextRefresh = entry.date.addingTimeInterval(5 * 60)
            }

            completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
        }
    }

    private func fetchEntry() async -> GoldPriceEntry {
        do {
            let quote = try await service.fetchQuote()
            return GoldPriceEntry(date: quote.fetchedAt, quote: quote, errorMessage: nil)
        } catch {
            return GoldPriceEntry(date: .now, quote: nil, errorMessage: error.localizedDescription)
        }
    }
}

struct GoldPriceWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "GoldPriceWidget", provider: GoldPriceTimelineProvider()) { entry in
            GoldPriceWidgetView(entry: entry)
        }
        .configurationDisplayName("国际金价")
        .description("在 macOS 桌面小组件里查看实时国际金价。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

private struct GoldPriceWidgetView: View {
    let entry: GoldPriceEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            switch family {
            case .systemMedium:
                mediumLayout
            default:
                smallLayout
            }
        }
        .containerBackground(for: .widget) {
            GoldPriceTheme.canvas
        }
    }

    private var smallLayout: some View {
        PixelPanel(fill: GoldPriceTheme.surface, padding: 12) {
            VStack(alignment: .leading, spacing: 10) {
                header

                if let quote = entry.quote {
                    metric(title: "USD / OZ", value: GoldPriceFormatting.usd(quote.pricePerOunce), size: 21)
                    metric(title: "RMB / 克", value: rmbPerGramText(for: quote), size: 16)

                    Spacer(minLength: 0)

                    footer("UPD \(GoldPriceFormatting.shortTime(quote.fetchedAt))")
                } else {
                    failureState
                }
            }
        }
    }

    private var mediumLayout: some View {
        PixelPanel(fill: GoldPriceTheme.surface, padding: 12) {
            VStack(alignment: .leading, spacing: 10) {
                header

                if let quote = entry.quote {
                    HStack(alignment: .top, spacing: 10) {
                        metricPanel(title: "USD / OZ", value: GoldPriceFormatting.usd(quote.pricePerOunce))
                        metricPanel(title: "RMB / 克", value: rmbPerGramText(for: quote))
                    }

                    HStack(spacing: 8) {
                        footer("UPD \(GoldPriceFormatting.shortTime(quote.fetchedAt))")
                        footer(quote.sourceName)
                    }
                } else {
                    failureState
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 8) {
            PixelCoinGlyph(size: 14)

            VStack(alignment: .leading, spacing: 3) {
                Text("国际金价")
                    .font(GoldPriceTheme.font(13, weight: .black))
                    .foregroundStyle(GoldPriceTheme.textPrimary)

                Text("PIXEL WIDGET")
                    .font(GoldPriceTheme.font(9, weight: .bold))
                    .foregroundStyle(GoldPriceTheme.textSecondary)
            }
        }
    }

    private var failureState: some View {
        PixelPanel(fill: GoldPriceTheme.negative.opacity(0.18), padding: 10) {
            VStack(alignment: .leading, spacing: 6) {
                Text("DATA OFFLINE")
                    .font(GoldPriceTheme.font(12, weight: .black))
                    .foregroundStyle(GoldPriceTheme.textPrimary)

                if let errorMessage = entry.errorMessage {
                    Text(errorMessage)
                        .font(GoldPriceTheme.font(10, weight: .bold))
                        .foregroundStyle(GoldPriceTheme.textSecondary)
                        .lineLimit(3)
                }
            }
        }
    }

    private func metric(title: String, value: String, size: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(GoldPriceTheme.font(10, weight: .bold))
                .foregroundStyle(GoldPriceTheme.textSecondary)

            Text(value)
                .font(GoldPriceTheme.font(size, weight: .black))
                .foregroundStyle(GoldPriceTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
    }

    private func metricPanel(title: String, value: String) -> some View {
        PixelPanel(fill: GoldPriceTheme.surfaceSecondary, padding: 10) {
            metric(title: title, value: value, size: 18)
        }
    }

    private func footer(_ text: String) -> some View {
        PixelPanel(fill: GoldPriceTheme.surfaceSecondary, padding: 8) {
            Text(text)
                .font(GoldPriceTheme.font(10, weight: .bold))
                .foregroundStyle(GoldPriceTheme.textPrimary)
                .lineLimit(1)
        }
    }

    private func rmbPerGramText(for quote: GoldQuote) -> String {
        guard let value = quote.pricePerGramCNY else {
            return "--"
        }

        return GoldPriceFormatting.rmb(value)
    }
}
