import Foundation

class HistoryViewModel: ObservableObject {
    @Published var collectedPackages: [ExpressPackage] = []
    @Published var searchText: String = ""

    private let storage = StorageService.shared

    var filteredPackages: [ExpressPackage] {
        if searchText.isEmpty {
            return collectedPackages
        }
        let query = searchText.lowercased()
        return collectedPackages.filter {
            $0.pickupCode.lowercased().contains(query) ||
            $0.company.lowercased().contains(query) ||
            $0.address.lowercased().contains(query)
        }
    }

    init() {
        refresh()
    }

    func refresh() {
        collectedPackages = storage.collectedPackages
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

    func clearAll() {
        storage.clearCollected()
        refresh()
    }
}
