import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var pendingPackages: [ExpressPackage] = []
    @Published var searchText: String = ""
    @Published var showAddSheet = false

    private let storage = StorageService.shared

    var filteredPackages: [ExpressPackage] {
        if searchText.isEmpty {
            return pendingPackages
        }
        let query = searchText.lowercased()
        return pendingPackages.filter {
            $0.pickupCode.lowercased().contains(query) ||
            $0.company.lowercased().contains(query) ||
            $0.address.lowercased().contains(query)
        }
    }

    init() {
        refresh()
    }

    func refresh() {
        pendingPackages = storage.pendingPackages
    }

    func markAsCollected(_ pkg: ExpressPackage) {
        storage.markAsCollected(pkg)
        refresh()
    }

    func deletePackage(_ pkg: ExpressPackage) {
        storage.deletePackage(pkg)
        refresh()
    }

    func deletePackages(at offsets: IndexSet) {
        let packagesToDelete = offsets.map { filteredPackages[$0] }
        for pkg in packagesToDelete {
            storage.deletePackage(pkg)
        }
        refresh()
    }
}
