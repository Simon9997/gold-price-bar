import Foundation

enum GoldPriceSourcePreference: String, CaseIterable, Identifiable, Codable {
    case automatic
    case kitco
    case goldAPI

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .automatic:
            return "自动"
        case .kitco:
            return "Kitco"
        case .goldAPI:
            return "Gold API"
        }
    }
}

struct GoldQuote: Equatable {
    let pricePerOunce: Double
    let fetchedAt: Date
    let sourceName: String
    let bidPerOunce: Double?
    let askPerOunce: Double?
    let usdToCNYRate: Double?

    var pricePerGram: Double {
        pricePerOunce / GoldPriceFormatting.gramsPerTroyOunce
    }

    var pricePerOunceCNY: Double? {
        guard let usdToCNYRate else {
            return nil
        }

        return pricePerOunce * usdToCNYRate
    }

    var pricePerGramCNY: Double? {
        guard let pricePerOunceCNY else {
            return nil
        }

        return pricePerOunceCNY / GoldPriceFormatting.gramsPerTroyOunce
    }

    static let preview = GoldQuote(
        pricePerOunce: 5_018.40,
        fetchedAt: .now.addingTimeInterval(-42),
        sourceName: "Preview",
        bidPerOunce: 5_017.8,
        askPerOunce: 5_019.0,
        usdToCNYRate: 7.20
    )
}

struct GoldPricePoint: Identifiable, Equatable {
    let timestamp: Date
    let pricePerOunce: Double

    var id: Date {
        timestamp
    }
}

struct GoldAPIResponse: Decodable {
    let name: String
    let price: Double
    let symbol: String
    let updatedAt: Date
    let updatedAtReadable: String?
}

struct KitcoPagePayload: Decodable {
    let props: Props

    struct Props: Decodable {
        let pageProps: PageProps
    }

    struct PageProps: Decodable {
        let dehydratedState: DehydratedState
    }

    struct DehydratedState: Decodable {
        let queries: [Query]
    }

    struct Query: Decodable {
        let state: QueryState
    }

    struct QueryState: Decodable {
        let data: KitcoData?
    }

    struct KitcoData: Decodable {
        let getMetalQuoteV3: MetalQuote?
        let cny: CurrencyQuote?

        enum CodingKeys: String, CodingKey {
            case getMetalQuoteV3 = "GetMetalQuoteV3"
            case cny = "CNY"
        }
    }

    struct MetalQuote: Decodable {
        let name: String
        let currency: String
        let results: [MetalQuoteResult]
    }

    struct MetalQuoteResult: Decodable {
        let ask: Double
        let bid: Double
        let mid: Double
        let timestamp: TimeInterval
    }

    struct CurrencyQuote: Decodable {
        let results: [CurrencyQuoteResult]
    }

    struct CurrencyQuoteResult: Decodable {
        let ask: Double
        let bid: Double
        let ctousd: Double?
        let usdtoc: Double?
        let timestamp: TimeInterval
    }
}
