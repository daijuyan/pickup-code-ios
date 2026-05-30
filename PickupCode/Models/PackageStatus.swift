import Foundation

enum PackageStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case collected = "collected"

    var displayName: String {
        switch self {
        case .pending: return "待取件"
        case .collected: return "已取件"
        }
    }
}
