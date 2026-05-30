import Foundation

struct ExpressPackage: Identifiable, Codable, Equatable {
    var id: UUID
    var pickupCode: String
    var company: String
    var address: String
    var cabinetNumber: String
    var courierPhone: String
    var trackingNumber: String
    var status: PackageStatus
    var pickupDeadline: Date?
    var remark: String
    var receivedTime: Date
    var collectedTime: Date?
    var smsSender: String
    var smsBody: String

    init(
        id: UUID = UUID(),
        pickupCode: String,
        company: String = "",
        address: String = "",
        cabinetNumber: String = "",
        courierPhone: String = "",
        trackingNumber: String = "",
        status: PackageStatus = .pending,
        pickupDeadline: Date? = nil,
        remark: String = "",
        receivedTime: Date = Date(),
        collectedTime: Date? = nil,
        smsSender: String = "",
        smsBody: String = ""
    ) {
        self.id = id
        self.pickupCode = pickupCode
        self.company = company
        self.address = address
        self.cabinetNumber = cabinetNumber
        self.courierPhone = courierPhone
        self.trackingNumber = trackingNumber
        self.status = status
        self.pickupDeadline = pickupDeadline
        self.remark = remark
        self.receivedTime = receivedTime
        self.collectedTime = collectedTime
        self.smsSender = smsSender
        self.smsBody = smsBody
    }
}
