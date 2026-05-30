import Foundation

struct ParsedSms {
    let pickupCode: String
    let company: String
    let address: String
    let cabinetNumber: String
    let courierPhone: String
    let trackingNumber: String
    let pickupDeadline: Date?
}

struct CourierRule {
    let companyName: String
    let senderKeywords: [String]
    let bodyKeywords: [String]
    let codePatterns: [String]
    let addressPatterns: [String]
}

class SmsParser {
    static let courierRules: [CourierRule] = [
        CourierRule(
            companyName: "菜鸟驿站",
            senderKeywords: ["菜鸟", "cainiao"],
            bodyKeywords: ["菜鸟驿站", "菜鸟包裹"],
            codePatterns: ["取件码[：:]?\s*(\d{4,8})", "验证码[：:]?\s*(\d{4,8})"],
            addressPatterns: ["菜鸟驿站\s*(.+?)(?=，|。|$)"]
        ),
        CourierRule(
            companyName: "丰巢",
            senderKeywords: ["丰巢", "fengchao"],
            bodyKeywords: ["丰巢", "丰巢智能柜"],
            codePatterns: ["取件码[：:]?\s*(\d{4,8})", "取[码碼][：:]?\s*(\d{4,8})"],
            addressPatterns: ["丰巢\s*(.+?)(?=，|。|$)"]
        ),
        CourierRule(
            companyName: "妈妈驿站",
            senderKeywords: ["妈妈驿站"],
            bodyKeywords: ["妈妈驿站"],
            codePatterns: ["取件码[：:]?\s*(\d{4,8})"],
            addressPatterns: ["妈妈驿站\s*(.+?)(?=，|。|$)"]
        ),
        CourierRule(
            companyName: "兔喜生活",
            senderKeywords: ["兔喜"],
            bodyKeywords: ["兔喜", "兔喜生活"],
            codePatterns: ["取件码[：:]?\s*(\d{4,8})"],
            addressPatterns: []
        ),
        CourierRule(
            companyName: "心愿智能柜",
            senderKeywords: ["心愿"],
            bodyKeywords: ["心愿", "智能柜"],
            codePatterns: ["取件码[：:]?\s*(\d{4,8})"],
            addressPatterns: []
        ),
        CourierRule(
            companyName: "顺丰速运",
            senderKeywords: ["顺丰", "shunfeng", "SF"],
            bodyKeywords: ["顺丰"],
            codePatterns: ["取件码[：:]?\s*(\d{4,8})", "验证码[：:]?\s*(\d{4,8})"],
            addressPatterns: ["顺丰\s*(.+?)(?=，|。|$)"]
        ),
        CourierRule(
            companyName: "中通快递",
            senderKeywords: ["中通", "zhongtong", "ZTO"],
            bodyKeywords: ["中通"],
            codePatterns: ["取件码[：:]?\s*(\d{4,8})"],
            addressPatterns: []
        ),
        CourierRule(
            companyName: "圆通速递",
            senderKeywords: ["圆通", "yuantong", "YTO"],
            bodyKeywords: ["圆通"],
            codePatterns: ["取件码[：:]?\s*(\d{4,8})"],
            addressPatterns: []
        ),
        CourierRule(
            companyName: "申通快递",
            senderKeywords: ["申通", "shentong", "STO"],
            bodyKeywords: ["申通"],
            codePatterns: ["取件码[：:]?\s*(\d{4,8})"],
            addressPatterns: []
        ),
        CourierRule(
            companyName: "韵达快递",
            senderKeywords: ["韵达", "yunda", "YD"],
            bodyKeywords: ["韵达"],
            codePatterns: ["取件码[：:]?\s*(\d{4,8})"],
            addressPatterns: []
        ),
        CourierRule(
            companyName: "京东物流",
            senderKeywords: ["京东", "jd"],
            bodyKeywords: ["京东", "京东物流"],
            codePatterns: ["取件码[：:]?\s*(\d{4,8})"],
            addressPatterns: []
        ),
        CourierRule(
            companyName: "极兔速递",
            senderKeywords: ["极兔", "jtexpress"],
            bodyKeywords: ["极兔"],
            codePatterns: ["取件码[：:]?\s*(\d{4,8})"],
            addressPatterns: []
        ),
        CourierRule(
            companyName: "邮政EMS",
            senderKeywords: ["邮政", "EMS", "ems"],
            bodyKeywords: ["邮政", "EMS"],
            codePatterns: ["取件码[：:]?\s*(\d{4,8})"],
            addressPatterns: []
        )
    ]

    static let generalCodePatterns = [
        "取件码[：:]?\s*(\d{4,8})",
        "取货码[：:]?\s*(\d{4,8})",
        "验证码[：:]?\s*(\d{4,8})",
        "取[码碼][：:]?\s*(\d{4,8})",
        "提取码[：:]?\s*([A-Za-z0-9]{4,8})",
        "取件码[为是]([A-Za-z0-9]{4,8})"
    ]

    static func parse(sender: String, body: String) -> ParsedSms? {
        let senderLower = sender.lowercased()
        let bodyLower = body.lowercased()

        var matchedCompany = ""
        var matchedRule: CourierRule?

        for rule in courierRules {
            let senderMatch = rule.senderKeywords.contains { senderLower.contains($0.lowercased()) }
            let bodyMatch = rule.bodyKeywords.contains { bodyLower.contains($0.lowercased()) }
            if senderMatch || bodyMatch {
                matchedCompany = rule.companyName
                matchedRule = rule
                break
            }
        }

        var code = ""

        if let rule = matchedRule {
            for pattern in rule.codePatterns {
                if let extracted = extractFirst(pattern: pattern, from: body) {
                    code = extracted
                    break
                }
            }
        }

        if code.isEmpty {
            for pattern in generalCodePatterns {
                if let extracted = extractFirst(pattern: pattern, from: body) {
                    code = extracted
                    break
                }
            }
        }

        guard !code.isEmpty else { return nil }

        if isPhoneNumber(code) { return nil }

        var address = ""
        if let rule = matchedRule {
            for pattern in rule.addressPatterns {
                if let extracted = extractFirst(pattern: pattern, from: body) {
                    address = extracted
                    break
                }
            }
        }

        if address.isEmpty {
            let addressPatterns = [
                "地址[：:]?\s*(.+?)(?=，|。|\n|$)",
                "地点[：:]?\s*(.+?)(?=，|。|\n|$)",
                "([\u{4e00}-\u{9fa5}]+(?:路|街|道|号|楼|栋|小区|单元).+?)(?=，|。|\n|$)"
            ]
            for pattern in addressPatterns {
                if let extracted = extractFirst(pattern: pattern, from: body) {
                    address = extracted
                    break
                }
            }
        }

        var trackingNumber = ""
        let trackingPatterns = [
            "单号[：:]?\s*([A-Za-z0-9]{10,20})",
            "运单[：:]?\s*([A-Za-z0-9]{10,20})",
            "快递[号单][：:]?\s*([A-Za-z0-9]{10,20})"
        ]
        for pattern in trackingPatterns {
            if let extracted = extractFirst(pattern: pattern, from: body) {
                trackingNumber = extracted
                break
            }
        }

        var courierPhone = ""
        let phonePatterns = [
            "电话[：:]?\s*(1[3-9]\d{9})",
            "联系[：:]?\s*(1[3-9]\d{9})",
            "(1[3-9]\d{9})"
        ]
        for pattern in phonePatterns {
            if let extracted = extractFirst(pattern: pattern, from: body) {
                courierPhone = extracted
                break
            }
        }

        if matchedCompany.isEmpty {
            matchedCompany = "快递"
        }

        return ParsedSms(
            pickupCode: code,
            company: matchedCompany,
            address: address,
            cabinetNumber: "",
            courierPhone: courierPhone,
            trackingNumber: trackingNumber,
            pickupDeadline: nil
        )
    }

    private static func extractFirst(pattern: String, from text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              match.numberOfRanges > 1,
              let codeRange = Range(match.range(at: 1), in: text) else {
            return nil
        }
        return String(text[codeRange])
    }

    private static func isPhoneNumber(_ code: String) -> Bool {
        let digits = code.filter { $0.isNumber }
        if digits.count >= 10 && digits.count <= 12 && digits.hasPrefix("1") {
            return true
        }
        return false
    }
}