import UserNotifications
import UIKit

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let bestAttemptContent = bestAttemptContent else { return }

        let title = bestAttemptContent.title
        let body = bestAttemptContent.body
        let subtitle = bestAttemptContent.subtitle
        let fullText = "\(title) \(subtitle) \(body)"

        // Parse pickup code from notification
        if let parsed = NotificationSmsParser.parse(text: fullText) {
            // Save to shared container
            saveDetectedPackage(parsed)

            // Modify notification to highlight the pickup code
            bestAttemptContent.title = "📦 \(parsed.company.isEmpty ? "快递" : parsed.company) - 取件码: \(parsed.pickupCode)"
            if !parsed.address.isEmpty {
                bestAttemptContent.subtitle = parsed.address
            }
            bestAttemptContent.body = body
            bestAttemptContent.sound = .default
            bestAttemptContent.badge = (getCurrentBadge() + 1) as NSNumber
        }

        contentHandler(bestAttemptContent)
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler,
           let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    // MARK: - Shared Storage

    private static let appGroupID = "group.com.codex.pickupcode"

    private func saveDetectedPackage(_ parsed: NotificationParsedSms) {
        guard let sharedDefaults = UserDefaults(suiteName: Self.appGroupID) else { return }

        let package: [String: Any] = [
            "id": UUID().uuidString,
            "pickupCode": parsed.pickupCode,
            "company": parsed.company,
            "address": parsed.address,
            "cabinetNumber": parsed.cabinetNumber,
            "courierPhone": parsed.courierPhone,
            "trackingNumber": parsed.trackingNumber,
            "status": "pending",
            "receivedTime": Date().timeIntervalSince1970,
            "source": "notification_extension"
        ]

        var pending = sharedDefaults.array(forKey: "pending_packages") as? [[String: Any]] ?? []
        // Deduplicate by pickup code
        let existingCodes = pending.compactMap { $0["pickupCode"] as? String }
        if !existingCodes.contains(parsed.pickupCode) {
            pending.insert(package, at: 0)
            sharedDefaults.set(pending, forKey: "pending_packages")
        }
    }

    private func getCurrentBadge() -> Int {
        guard let sharedDefaults = UserDefaults(suiteName: Self.appGroupID) else { return 0 }
        return sharedDefaults.integer(forKey: "badge_count")
    }
}

// MARK: - Notification SMS Parser (self-contained for extension)

struct NotificationParsedSms {
    let pickupCode: String
    let company: String
    let address: String
    let cabinetNumber: String
    let courierPhone: String
    let trackingNumber: String
}

struct NotificationSmsParser {

    struct CourierRule {
        let companyName: String
        let keywords: [String]
        let codePatterns: [String]
    }

    static let courierRules: [CourierRule] = [
        CourierRule(companyName: "菜鸟驿站", keywords: ["菜鸟", "cainiao"],
                    codePatterns: ["取件码[：:]?\\s*(\\d{4,8})", "验证码[：:]?\\s*(\\d{4,8})"]),
        CourierRule(companyName: "丰巢", keywords: ["丰巢", "fengchao"],
                    codePatterns: ["取件码[：:]?\\s*(\\d{4,8})", "凭[码碼][：:]?\\s*(\\d{4,8})"]),
        CourierRule(companyName: "妈妈驿站", keywords: ["妈妈驿站"],
                    codePatterns: ["取件码[：:]?\\s*(\\d{4,8})"]),
        CourierRule(companyName: "兔喜生活", keywords: ["兔喜"],
                    codePatterns: ["取件码[：:]?\\s*(\\d{4,8})"]),
        CourierRule(companyName: "心甜智能柜", keywords: ["心甜"],
                    codePatterns: ["取件码[：:]?\\s*(\\d{4,8})"]),
        CourierRule(companyName: "顺丰速运", keywords: ["顺丰", "shunfeng", "SF"],
                    codePatterns: ["取件码[：:]?\\s*(\\d{4,8})", "验证码[：:]?\\s*(\\d{4,8})"]),
        CourierRule(companyName: "中通快递", keywords: ["中通", "zhongtong", "ZTO"],
                    codePatterns: ["取件码[：:]?\\s*(\\d{4,8})"]),
        CourierRule(companyName: "圆通速递", keywords: ["圆通", "yuantong", "YTO"],
                    codePatterns: ["取件码[：:]?\\s*(\\d{4,8})"]),
        CourierRule(companyName: "申通快递", keywords: ["申通", "shentong", "STO"],
                    codePatterns: ["取件码[：:]?\\s*(\\d{4,8})"]),
        CourierRule(companyName: "韵达快递", keywords: ["韵达", "yunda", "YD"],
                    codePatterns: ["取件码[：:]?\\s*(\\d{4,8})"]),
        CourierRule(companyName: "京东物流", keywords: ["京东", "jd"],
                    codePatterns: ["取件码[：:]?\\s*(\\d{4,8})"]),
        CourierRule(companyName: "极兔速递", keywords: ["极兔", "jtexpress"],
                    codePatterns: ["取件码[：:]?\\s*(\\d{4,8})"]),
        CourierRule(companyName: "邮政EMS", keywords: ["邮政", "EMS", "ems"],
                    codePatterns: ["取件码[：:]?\\s*(\\d{4,8})"])
    ]

    static let generalPatterns = [
        "取件码[：:]?\\s*(\\d{4,8})",
        "取货码[：:]?\\s*(\\d{4,8})",
        "验证码[：:]?\\s*(\\d{4,8})",
        "凭[码碼][：:]?\\s*(\\d{4,8})",
        "提取码[：:]?\\s*([A-Za-z0-9]{4,8})",
        "取件码[为是]([A-Za-z0-9]{4,8})"
    ]

    static func parse(text: String) -> NotificationParsedSms? {
        let lower = text.lowercased()

        // Match courier
        var company = ""
        var matchedRule: CourierRule?
        for rule in courierRules {
            if rule.keywords.contains(where: { lower.contains($0.lowercased()) }) {
                company = rule.companyName
                matchedRule = rule
                break
            }
        }

        // Extract code
        var code = ""
        if let rule = matchedRule {
            for p in rule.codePatterns {
                if let c = extract(pattern: p, from: text) { code = c; break }
            }
        }
        if code.isEmpty {
            for p in generalPatterns {
                if let c = extract(pattern: p, from: text) { code = c; break }
            }
        }
        guard !code.isEmpty else { return nil }
        if isPhoneNumber(code) { return nil }

        // Extract address
        var address = ""
        let addrPatterns = [
            "地址[：:]?\\s*(.+?)(?=，|。|\\n|$)",
            "地点[：:]?\\s*(.+?)(?=，|。|\\n|$)"
        ]
        for p in addrPatterns {
            if let a = extract(pattern: p, from: text) { address = a; break }
        }

        // Extract phone
        var phone = ""
        let phonePatterns = ["电话[：:]?\\s*(1[3-9]\\d{9})", "(1[3-9]\\d{9})"]
        for p in phonePatterns {
            if let ph = extract(pattern: p, from: text) { phone = ph; break }
        }

        // Extract tracking
        var tracking = ""
        let trackPatterns = [
            "单号[：:]?\\s*([A-Za-z0-9]{10,20})",
            "运单[：:]?\\s*([A-Za-z0-9]{10,20})"
        ]
        for p in trackPatterns {
            if let t = extract(pattern: p, from: text) { tracking = t; break }
        }

        return NotificationParsedSms(
            pickupCode: code,
            company: company.isEmpty ? "快递" : company,
            address: address,
            cabinetNumber: "",
            courierPhone: phone,
            trackingNumber: tracking
        )
    }

    private static func extract(pattern: String, from text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              match.numberOfRanges > 1,
              let r = Range(match.range(at: 1), in: text) else { return nil }
        return String(text[r])
    }

    private static func isPhoneNumber(_ code: String) -> Bool {
        let digits = code.filter { $0.isNumber }
        return digits.count >= 10 && digits.count <= 12 && digits.hasPrefix("1")
    }
}
