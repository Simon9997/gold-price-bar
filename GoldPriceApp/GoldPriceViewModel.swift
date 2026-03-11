import Foundation

@MainActor
final class GoldPriceViewModel: ObservableObject {
    static let maxHistoryPoints = 1_800
    private static let sourcePreferenceKey = "gold_price_source_preference"
    private static let compactHistoryWindow: TimeInterval = 90
    private static let chartHistoryWindow: TimeInterval = 4 * 60
    private static let minimumHistoryStep: TimeInterval = 0.001

    @Published private(set) var quote: GoldQuote?
    @Published private(set) var history: [GoldPricePoint] = []
    @Published private(set) var isRefreshing = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var selectedSource: GoldPriceSourcePreference

    private let service: GoldPriceService
    private let refreshInterval: Duration
    private var refreshTask: Task<Void, Never>?
    private let userDefaults: UserDefaults
    private var refreshSequence = 0

    init(
        service: GoldPriceService = GoldPriceService(),
        refreshInterval: Duration = .seconds(1),
        autoStart: Bool = false,
        userDefaults: UserDefaults = .standard
    ) {
        self.selectedSource = Self.loadSourcePreference(from: userDefaults)
        self.service = service
        self.refreshInterval = refreshInterval
        self.userDefaults = userDefaults

        if autoStart {
            start()
        }
    }

    deinit {
        refreshTask?.cancel()
    }

    func start() {
        guard refreshTask == nil else {
            return
        }

        refreshTask = Task { [weak self] in
            guard let self else {
                return
            }

            let clock = ContinuousClock()
            while !Task.isCancelled {
                let cycleStartedAt = clock.now
                await refresh()

                do {
                    try await clock.sleep(
                        until: cycleStartedAt.advanced(by: refreshInterval),
                        tolerance: .milliseconds(100)
                    )
                } catch {
                    return
                }
            }
        }
    }

    func stop() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    func refresh() async {
        guard !isRefreshing else {
            return
        }

        let requestSource = selectedSource
        let requestSequence = refreshSequence
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            let quote = try await service.fetchQuote(preferredSource: requestSource)
            guard requestSequence == refreshSequence, requestSource == selectedSource else {
                return
            }
            apply(quote)
            errorMessage = nil
        } catch {
            guard requestSequence == refreshSequence, requestSource == selectedSource else {
                return
            }
            errorMessage = error.localizedDescription
        }
    }

    func changeSource(to newSource: GoldPriceSourcePreference) async {
        guard newSource != selectedSource else {
            await refresh()
            return
        }

        selectedSource = newSource
        userDefaults.set(newSource.rawValue, forKey: Self.sourcePreferenceKey)
        refreshSequence += 1
        history.removeAll()
        quote = nil
        errorMessage = nil

        while isRefreshing {
            try? await Task.sleep(for: .milliseconds(50))
        }

        await refresh()
    }

    var sessionHigh: Double? {
        history.map(\.pricePerOunce).max()
    }

    var sessionLow: Double? {
        history.map(\.pricePerOunce).min()
    }

    var sessionMove: String? {
        guard let first = history.first?.pricePerOunce, let last = history.last?.pricePerOunce else {
            return nil
        }

        return GoldPriceFormatting.sessionMoveText(from: first, to: last)
    }

    var sessionChangePercent: Double? {
        guard let first = history.first?.pricePerOunce, let last = history.last?.pricePerOunce else {
            return nil
        }

        return GoldPriceFormatting.signedPercent(from: first, to: last)
    }

    var latestPriceText: String {
        guard let quote else {
            return "--"
        }

        return GoldPriceFormatting.usd(quote.pricePerOunce)
    }

    var latestPerGramText: String {
        guard let quote else {
            return "--"
        }

        return GoldPriceFormatting.usd(quote.pricePerGram)
    }

    var latestPriceCNYText: String {
        guard let quote, let value = quote.pricePerOunceCNY else {
            return "--"
        }

        return GoldPriceFormatting.rmb(value)
    }

    var latestPerGramCNYText: String {
        guard let quote, let value = quote.pricePerGramCNY else {
            return "--"
        }

        return GoldPriceFormatting.rmb(value)
    }

    var latestUpdatedText: String? {
        guard let fetchedAt = quote?.fetchedAt else {
            return nil
        }

        return GoldPriceFormatting.shortTime(fetchedAt)
    }

    var menuBarTitle: String {
        guard let quote else {
            return "Gold"
        }

        return GoldPriceFormatting.menuBarPrice(quote.pricePerOunce)
    }

    var compactHistory: [GoldPricePoint] {
        historyPoints(within: Self.compactHistoryWindow)
    }

    var chartHistory: [GoldPricePoint] {
        historyPoints(within: Self.chartHistoryWindow)
    }

    var sourceName: String {
        quote?.sourceName ?? selectedSource.displayName
    }

    private static func loadSourcePreference(from userDefaults: UserDefaults) -> GoldPriceSourcePreference {
        guard
            let rawValue = userDefaults.string(forKey: sourcePreferenceKey),
            let preference = GoldPriceSourcePreference(rawValue: rawValue)
        else {
            return .automatic
        }

        return preference
    }

    private func apply(_ quote: GoldQuote) {
        let previousQuote = self.quote
        self.quote = quote

        guard shouldAppendHistoryPoint(for: quote, previousQuote: previousQuote) else {
            return
        }

        // Chart x-values must stay strictly increasing. Upstream timestamps can
        // repeat or move backward, which makes the line fold onto itself.
        let point = GoldPricePoint(
            timestamp: nextHistoryTimestamp(),
            pricePerOunce: quote.pricePerOunce
        )
        history.append(point)

        if history.count > Self.maxHistoryPoints {
            history.removeFirst(history.count - Self.maxHistoryPoints)
        }
    }

    private func shouldAppendHistoryPoint(for quote: GoldQuote, previousQuote: GoldQuote?) -> Bool {
        guard let previousQuote else {
            return true
        }

        return previousQuote.sourceUpdatedAt != quote.sourceUpdatedAt
            || previousQuote.pricePerOunce != quote.pricePerOunce
            || previousQuote.bidPerOunce != quote.bidPerOunce
            || previousQuote.askPerOunce != quote.askPerOunce
            || previousQuote.sourceName != quote.sourceName
    }

    private func historyPoints(within window: TimeInterval) -> [GoldPricePoint] {
        guard let latestTimestamp = history.last?.timestamp else {
            return []
        }

        // Keep the chart frozen until a fresh upstream sample is appended.
        let cutoff = latestTimestamp.addingTimeInterval(-window)
        return history.filter { $0.timestamp >= cutoff }
    }

    private func nextHistoryTimestamp() -> Date {
        let now = Date()

        guard let lastTimestamp = history.last?.timestamp, now <= lastTimestamp else {
            return now
        }

        return lastTimestamp.addingTimeInterval(Self.minimumHistoryStep)
    }
}
