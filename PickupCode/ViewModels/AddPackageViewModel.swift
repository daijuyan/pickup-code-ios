import Foundation

class AddPackageViewModel: ObservableObject {
    @Published var pickupCode: String = ""
    @Published var company: String = ""
    @Published var address: String = ""
    @Published var cabinetNumber: String = ""
    @Published var courierPhone: String = ""
    @Published var trackingNumber: String = ""
    @Published var remark: String = ""
    @Published var smsText: String = ""

    @Published var showSuccess = false
    @Published var showError = false
    @Published var errorMessage = ""

    private let storage = StorageService.shared

    var isValid: Bool {
        !pickupCode.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func save() {
        let code = pickupCode.trimmingCharacters(in: .whitespaces)
        guard !code.isEmpty else {
            showError = true
            errorMessage = "请输入取件码"
            return
        }

        let pkg = ExpressPackage(
            pickupCode: code,
            company: company.trimmingCharacters(in: .whitespaces),
            address: address.trimmingCharacters(in: .whitespaces),
            cabinetNumber: cabinetNumber.trimmingCharacters(in: .whitespaces),
            courierPhone: courierPhone.trimmingCharacters(in: .whitespaces),
            trackingNumber: trackingNumber.trimmingCharacters(in: .whitespaces),
            remark: remark.trimmingCharacters(in: .whitespaces)
        )

        storage.addPackage(pkg)
        NotificationService.shared.scheduleNewPackageNotification(
            company: pkg.company, code: pkg.pickupCode, address: pkg.address
        )
        showSuccess = true
        clearForm()
    }

    func parseFromSms() {
        let text = smsText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            showError = true
            errorMessage = "请粘贴短信内容"
            return
        }

        guard let parsed = SmsParser.parse(sender: "", body: text) else {
            showError = true
            errorMessage = "未能从短信中识别取件码"
            return
        }

        pickupCode = parsed.pickupCode
        company = parsed.company
        address = parsed.address
        courierPhone = parsed.courierPhone
        trackingNumber = parsed.trackingNumber
    }

    private func clearForm() {
        pickupCode = ""
        company = ""
        address = ""
        cabinetNumber = ""
        courierPhone = ""
        trackingNumber = ""
        remark = ""
        smsText = ""
    }
}