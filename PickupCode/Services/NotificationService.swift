import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    func scheduleNewPackageNotification(company: String, code: String, address: String) {
        let content = UNMutableNotificationContent()
        content.title = "新快递到站"
        content.subtitle = "\(company) - 取件码: \(code)"
        content.body = address.isEmpty ? "请尽快取件" : "取件地址: \(address)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "new_package_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleDeadlineReminder(pkg: ExpressPackage, minutesBefore: Int = 30) {
        guard let deadline = pkg.pickupDeadline else { return }

        let reminderDate = deadline.addingTimeInterval(-Double(minutesBefore * 60))
        guard reminderDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "取件提醒"
        content.body = "快递 \(pkg.company) \(pkg.pickupCode) 即将到期，请尽快取件！"
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "deadline_\(pkg.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func cancelDeadlineReminder(for pkg: ExpressPackage) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["deadline_\(pkg.id.uuidString)"])
    }
}