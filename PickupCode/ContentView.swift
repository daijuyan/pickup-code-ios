import SwiftUI
import UserNotifications

struct ContentView: View {
    @StateObject private var settings = SettingsViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var shortcutService: ShortcutService

    @State private var showClipboardAlert = false
    @State private var clipboardPackage: ExpressPackage?

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("待取件", systemImage: "shippingbox.fill")
                }

            HistoryView()
                .tabItem {
                    Label("已取件", systemImage: "checkmark.circle.fill")
                }

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
        }
        .preferredColorScheme(settings.colorScheme)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                StorageService.shared.syncFromNotificationExtension()
                UIApplication.shared.applicationIconBadgeNumber = 0

                // Check clipboard for pickup code from Shortcuts
                if let pkg = shortcutService.checkClipboardForPickupCode() {
                    clipboardPackage = pkg
                    showClipboardAlert = true
                }
            }
        }
        .alert("发现取件码", isPresented: $showClipboardAlert) {
            Button("添加到待取件") {
                if let pkg = clipboardPackage {
                    StorageService.shared.addPackage(pkg)
                    NotificationService.shared.scheduleNewPackageNotification(
                        company: pkg.company, code: pkg.pickupCode, address: pkg.address
                    )
                }
                clipboardPackage = nil
            }
            Button("忽略", role: .cancel) {
                clipboardPackage = nil
            }
        } message: {
            if let pkg = clipboardPackage {
                Text("从剪贴板检测到取件码：\(pkg.pickupCode)\n\(pkg.company)")
            }
        }
        .alert("取件码已存在", isPresented: $shortcutService.showReceivedAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            if let code = shortcutService.lastReceivedCode {
                Text("取件码 \(code) 已在待取件列表中")
            }
        }
    }
}