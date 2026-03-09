import Foundation

enum GoldPriceFormatting {
    static let gramsPerTroyOunce = 31.1034768

    static func usd(_ value: Double, fractionDigits: Int = 2) -> String {
        currency(value, code: "USD", fractionDigits: fractionDigits)
    }

    static func cny(_ value: Double, fractionDigits: Int = 2) -> String {
        currency(value, code: "CNY", fractionDigits: fractionDigits)
    }

    static func rmb(_ value: Double, fractionDigits: Int = 2) -> String {
        "RMB \(plain(value, fractionDigits: fractionDigits))"
    }

    static func currency(_ value: Double, code: String, fractionDigits: Int = 2) -> String {
        value.formatted(
            .currency(code: code)
                .precision(.fractionLength(fractionDigits))
        )
    }

    static func plain(_ value: Double, fractionDigits: Int = 2) -> String {
        value.formatted(
            .number
                .grouping(.automatic)
                .precision(.fractionLength(fractionDigits))
        )
    }

    static func menuBarPrice(_ value: Double) -> String {
        "$\(plain(value))"
    }

    static func shortTime(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    static func sessionMoveText(from firstValue: Double, to lastValue: Double) -> String {
        let delta = lastValue - firstValue
        let percent = (delta / firstValue) * 100
        let sign = delta >= 0 ? "+" : ""
        return "\(sign)\(usd(delta))  (\(sign)\(percent.formatted(.number.precision(.fractionLength(2))))%)"
    }

    static func signedPercent(from firstValue: Double, to lastValue: Double) -> Double {
        ((lastValue - firstValue) / firstValue) * 100
    }
}
