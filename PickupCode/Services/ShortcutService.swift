import Foundation
import UIKit

class ShortcutService: ObservableObject {
    static let shared = ShortcutService()

    static let urlScheme = "pickupcode"
    static let appGroupID = "group.com.codex.pickupcode"

    @Published var lastReceivedCode: String?
    @Published var showReceivedAlert = false

    private init() {}

    // MARK: - URL Scheme Handling

    func handleURL(_ url: URL) -> Bool {
        guard url.scheme == Self.urlScheme else { return false }

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }

        let params = components.queryItems ?? []

        let code = params.first(where: { $0.name == "code" })?.value ?? ""
        let company = params.first(where: { $0.name == "company" })?.value ?? ""
        let address = params.first(where: { $0.name == "address" })?.value ?? ""
        let body = params.first(where: { $0.name == "body" })?.value ?? ""
        let phone = params.first(where: { $0.name == "phone" })?.value ?? ""
        let tracking = params.first(where: { $0.name == "tracking" })?.value ?? ""

        guard !code.isEmpty else { return false }

        var finalCompany = company
        var finalAddress = address
        var finalPhone = phone
        var finalTracking = tracking

        if !body.isEmpty, let parsed = SmsParser.parse(sender: "", body: body) {
            if finalCompany.isEmpty { finalCompany = parsed.company }
            if finalAddress.isEmpty { finalAddress = parsed.address }
            if finalPhone.isEmpty { finalPhone = parsed.courierPhone }
            if finalTracking.isEmpty { finalTracking = parsed.trackingNumber }
        }

        let existing = StorageService.shared.packages.map { $0.pickupCode }
        guard !existing.contains(code) else {
            DispatchQueue.main.async {
                self.lastReceivedCode = code
                self.showReceivedAlert = true
            }
            return true
        }

        let pkg = ExpressPackage(
            pickupCode: code,
            company: finalCompany.isEmpty ? "快递" : finalCompany,
            address: finalAddress,
            courierPhone: finalPhone,
            trackingNumber: finalTracking,
            status: .pending,
            smsBody: body
        )

        StorageService.shared.addPackage(pkg)
        NotificationService.shared.scheduleNewPackageNotification(
            company: pkg.company, code: pkg.pickupCode, address: pkg.address
        )

        DispatchQueue.main.async {
            self.lastReceivedCode = code
            self.showReceivedAlert = true
        }

        return true
    }

    // MARK: - Clipboard Check

    func checkClipboardForPickupCode() -> ExpressPackage? {
        guard UIPasteboard.general.hasStrings else { return nil }

        let clipboard = UIPasteboard.general.string ?? ""
        guard !clipboard.isEmpty, clipboard.count <= 200 else { return nil }

        if let parsed = SmsParser.parse(sender: "", body: clipboard) {
            let existing = StorageService.shared.packages.map { $0.pickupCode }
            guard !existing.contains(parsed.pickupCode) else { return nil }

            let pkg = ExpressPackage(
                pickupCode: parsed.pickupCode,
                company: parsed.company.isEmpty ? "快递" : parsed.company,
                address: parsed.address,
                courierPhone: parsed.courierPhone,
                trackingNumber: parsed.trackingNumber,
                status: .pending,
                smsBody: clipboard
            )
            return pkg
        }

        let trimmed = clipboard.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count >= 4, trimmed.count <= 8,
           trimmed.allSatisfy({ $0.isNumber }) {
            let existing = StorageService.shared.packages.map { $0.pickupCode }
            guard !existing.contains(trimmed) else { return nil }

            return ExpressPackage(
                pickupCode: trimmed,
                company: "快递",
                status: .pending
            )
        }

        return nil
    }

    // MARK: - Shortcut Steps

    func generateShortcutSteps() -> [(step: Int, title: String, detail: String)] {
        return [
            (1, "打开「快捷指令」App", "在 iPhone 上找到并打开快捷指令应用"),
            (2, "创建新快捷指令", "点击右上角 + 号创建新的快捷指令"),
            (3, "添加「获取文本」操作", "搜索并添加「获取文本」操作，输入设为快捷指令输入"),
            (4, "添加「匹配文本」操作", "搜索并添加「匹配文本」操作，正则表达式填写：取件码[：:]?\\s*(\\d{4,8})"),
            (5, "添加「获取匹配组」操作", "搜索并添加「获取匹配的组」操作，获取第一组"),
            (6, "添加「打开 URL」操作", "搜索并添加「打开 URL」操作，URL 填写：pickupcode://add?code=[匹配结果]"),
            (7, "保存快捷指令", "点击完成，给快捷指令取名如「快递取件码识别」"),
            (8, "打开「自动化」标签", "在快捷指令 App 底部切换到「自动化」标签"),
            (9, "配置触发条件", "选择「创建个人自动化」→「信息」，包含关键词填：取件码"),
            (10, "选择运行快捷指令", "选择刚才创建的「快递取件码识别」快捷指令"),
            (11, "关闭「运行前询问」", "设置为不询问，实现全自动识别")
        ]
    }

    // MARK: - Export Shortcut

    func exportShortcutPlist() -> Data? {
        let shortcut: [String: Any] = [
            "WFWorkflowMinimumClientVersionString": "900",
            "WFWorkflowMinimumClientVersion": 900,
            "WFWorkflowIcon": [
                "WFWorkflowIconStartColor": 4282601983,
                "WFWorkflowIconGlyphNumber": 59742
            ] as [String: Any],
            "WFWorkflowClientVersion": "2516.0.4",
            "WFWorkflowOutputContentItemClasses": [],
            "WFWorkflowHasOutputFallback": false,
            "WFWorkflowActions": [
                [
                    "WFWorkflowActionIdentifier": "is.workflow.actions.detect.text",
                    "WFWorkflowActionParameters": [
                        "WFInput": [
                            "Value": [
                                "Type": "Variable",
                                "VariableName": "ShortcutInput"
                            ] as [String: Any],
                            "WFSerializationType": "WFTextTokenAttachment"
                        ] as [String: Any]
                    ] as [String: Any]
                ] as [String: Any],
                [
                    "WFWorkflowActionIdentifier": "is.workflow.actions.text.match",
                    "WFWorkflowActionParameters": [
                        "WFMatchTextPattern": "取件码[：:]?\s*(\d{4,8})",
                        "text": [
                            "Value": [
                                "attachmentsByRange": [
                                    "{0, 1}": [
                                        "Type": "ActionOutput",
                                        "OutputName": "文本",
                                        "OutputUUID": "TEXT-UUID"
                                    ] as [String: Any]
                                ] as [String: Any],
                                "string": "\u{FFFC}"
                            ] as [String: Any],
                            "WFSerializationType": "WFTextTokenString"
                        ] as [String: Any]
                    ] as [String: Any]
                ] as [String: Any],
                [
                    "WFWorkflowActionIdentifier": "is.workflow.actions.text.match.getgroup",
                    "WFWorkflowActionParameters": [
                        "WFGetGroupType": "First Group",
                        "matches": [
                            "Value": [
                                "attachmentsByRange": [
                                    "{0, 1}": [
                                        "Type": "ActionOutput",
                                        "OutputName": "匹配",
                                        "OutputUUID": "MATCH-UUID"
                                    ] as [String: Any]
                                ] as [String: Any],
                                "string": "\u{FFFC}"
                            ] as [String: Any],
                            "WFSerializationType": "WFTextTokenString"
                        ] as [String: Any]
                    ] as [String: Any]
                ] as [String: Any],
                [
                    "WFWorkflowActionIdentifier": "is.workflow.actions.openurl",
                    "WFWorkflowActionParameters": [
                        "WFInput": [
                            "Value": [
                                "attachmentsByRange": [
                                    "{0, 1}": [
                                        "Type": "ActionOutput",
                                        "OutputName": "文本",
                                        "OutputUUID": "GROUP-UUID"
                                    ] as [String: Any]
                                ] as [String: Any],
                                "string": "pickupcode://add?code=\u{FFFC}"
                            ] as [String: Any],
                            "WFSerializationType": "WFTextTokenString"
                        ] as [String: Any]
                    ] as [String: Any]
                ] as [String: Any]
            ],
            "WFWorkflowImportQuestions": [],
            "WFWorkflowTypes": ["NCWidget", "WatchKit"],
            "WFWorkflowHasShortcutInputVariables": true
        ]

        return try? PropertyListSerialization.data(fromPropertyList: shortcut, format: .binary, options: 0)
    }
}