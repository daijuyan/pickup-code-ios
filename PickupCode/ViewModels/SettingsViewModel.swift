import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @AppStorage("themeMode") var themeMode: String = "system"
    @Published var showClearConfirm = false
    @Published var showClearResult = false
    @Published var clearResultMessage = ""

    private let storage = StorageService.shared

    var colorScheme: ColorScheme? {
        switch themeMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    func setTheme(_ mode: String) {
        themeMode = mode
    }

    func clearAllData() {
        storage.clearAll()
        clearResultMessage = "所有数据已清空"
        showClearResult = true
    }

    func clearCollectedData() {
        storage.clearCollected()
        clearResultMessage = "已取件记录已清空"
        showClearResult = true
    }

    func requestNotificationPermission() {
        Task {
            _ = await NotificationService.shared.requestPermission()
        }
    }
}