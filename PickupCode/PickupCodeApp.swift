import SwiftUI

@main
struct PickupCodeApp: App {
    @State private var notificationGranted = false
    @StateObject private var shortcutService = ShortcutService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(shortcutService)
                .task {
                    notificationGranted = await NotificationService.shared.requestPermission()
                }
                .onOpenURL { url in
                    _ = shortcutService.handleURL(url)
                }
        }
    }
}
