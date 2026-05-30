import Foundation
import SwiftUI

class StorageService: ObservableObject {
    static let shared = StorageService()

    @Published var packages: [ExpressPackage] = []

    private let fileName = "packages.json"
    private static let appGroupID = "group.com.codex.pickupcode"

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    // Cache App Group availability to avoid repeated checks
    private var _appGroupAvailable: Bool?
    private var isAppGroupAvailable: Bool {
        if let cached = _appGroupAvailable { return cached }
        let available = UserDefaults(suiteName: Self.appGroupID) != nil
        _appGroupAvailable = available
        return available
    }

    private init() {
        load()
        syncFromNotificationExtension()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([ExpressPackage].self, from: data) else {
            packages = []
            return
        }
        packages = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(packages) else { return }
        try? data.write(to: fileURL)
    }

    // MARK: - Notification Extension Sync

    func syncFromNotificationExtension() {
        guard isAppGroupAvailable,
              let sharedDefaults = UserDefaults(suiteName: Self.appGroupID) else { return }

        let pending = sharedDefaults.array(forKey: "pending_packages") as? [[String: Any]] ?? []
        guard !pending.isEmpty else { return }

        let existingCodes = Set(packages.map { $0.pickupCode })
        var added = 0

        for dict in pending {
            guard let code = dict["pickupCode"] as? String,
                  !existingCodes.contains(code) else { continue }

            let idStr = dict["id"] as? String ?? UUID().uuidString
            let company = dict["company"] as? String ?? ""
            let address = dict["address"] as? String ?? ""
            let cabinet = dict["cabinetNumber"] as? String ?? ""
            let phone = dict["courierPhone"] as? String ?? ""
            let tracking = dict["trackingNumber"] as? String ?? ""
            let ts = dict["receivedTime"] as? Double ?? Date().timeIntervalSince1970

            let pkg = ExpressPackage(
                id: UUID(uuidString: idStr) ?? UUID(),
                pickupCode: code,
                company: company,
                address: address,
                cabinetNumber: cabinet,
                courierPhone: phone,
                trackingNumber: tracking,
                status: .pending,
                receivedTime: Date(timeIntervalSince1970: ts),
                smsSender: "",
                smsBody: ""
            )
            packages.insert(pkg, at: 0)
            added += 1
        }

        if added > 0 {
            save()
            sharedDefaults.removeObject(forKey: "pending_packages")
        }
    }

    // MARK: - CRUD

    func addPackage(_ pkg: ExpressPackage) {
        packages.insert(pkg, at: 0)
        save()
    }

    func updatePackage(_ pkg: ExpressPackage) {
        if let idx = packages.firstIndex(where: { $0.id == pkg.id }) {
            packages[idx] = pkg
            save()
        }
    }

    func markAsCollected(_ pkg: ExpressPackage) {
        var updated = pkg
        updated.status = .collected
        updated.collectedTime = Date()
        updatePackage(updated)
    }

    func deletePackage(_ pkg: ExpressPackage) {
        packages.removeAll { $0.id == pkg.id }
        save()
    }

    func clearAll() {
        packages.removeAll()
        save()
        if isAppGroupAvailable {
            UserDefaults(suiteName: Self.appGroupID)?.removeObject(forKey: "pending_packages")
        }
    }

    func clearCollected() {
        packages.removeAll { $0.status == .collected }
        save()
    }

    var pendingPackages: [ExpressPackage] {
        packages.filter { $0.status == .pending }
            .sorted { $0.receivedTime > $1.receivedTime }
    }

    var collectedPackages: [ExpressPackage] {
        packages.filter { $0.status == .collected }
            .sorted { ($0.collectedTime ?? .distantPast) > ($1.collectedTime ?? .distantPast) }
    }
}