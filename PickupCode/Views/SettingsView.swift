import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showShortcutSetup = false

    var body: some View {
        NavigationStack {
            Form {
                // Theme
                Section {
                    ForEach(["light", "dark", "system"], id: \.self) { mode in
                        Button(action: { viewModel.setTheme(mode) }) {
                            HStack {
                                Text(themeDisplayName(mode))
                                    .foregroundColor(.primary)

                                Spacer()

                                if viewModel.themeMode == mode {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                } header: {
                    Text("主题设置")
                }

                // Shortcut integration
                Section {
                    Button(action: { showShortcutSetup = true }) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("配置快捷指令自动识别")
                                    .foregroundColor(.primary)
                                Text("从短信自动提取取件码，推荐配置")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Button(action: {
                        UIPasteboard.general.string = "pickupcode://add?code="
                    }) {
                        HStack {
                            Image(systemName: "link")
                            Text("复制 URL Scheme")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("pickupcode://")
                                .font(.caption.monospaced())
                                .foregroundColor(.secondary)
                        }
                    }

                    Button(action: {
                        UIPasteboard.general.string = "取件码[：:]?\s*(\d{4,8})"
                    }) {
                        HStack {
                            Image(systemName: "textformat")
                            Text("复制取件码正则")
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                } header: {
                    Text("快捷指令（短信识别）")
                } footer: {
                    Text("通过 iOS 快捷指令自动化，拦截快递短信并自动提取取件码。这是 iOS 上唯一合规读取短信取件码的方案。")
                }

                // Notification
                Section {
                    Button(action: { viewModel.requestNotificationPermission() }) {
                        HStack {
                            Image(systemName: "bell")
                            Text("开启通知权限")
                        }
                    }

                    Button(action: {
                        NotificationService.shared.scheduleNewPackageNotification(
                            company: "测试快递", code: "TEST-001", address: "测试取件地址"
                        )
                    }) {
                        HStack {
                            Image(systemName: "speaker.wave.2")
                            Text("播放测试通知")
                        }
                    }
                } header: {
                    Text("通知设置")
                } footer: {
                    Text("如果收不到通知，请在系统设置中检查通知权限")
                }

                // Data management
                Section {
                    Button(action: { viewModel.showClearConfirm = true }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("清空所有数据")
                                .foregroundColor(.red)
                        }
                    }
                } header: {
                    Text("数据管理")
                } footer: {
                    Text("清空后无法恢复，请谨慎操作")
                }

                // About
                Section {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("快递取件码")
                        Spacer()
                        Text("自动识别和管理快递取件码")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("关于")
                }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showShortcutSetup) {
                ShortcutSetupView()
            }
            .confirmationDialog("确认清空", isPresented: $viewModel.showClearConfirm) {
                Button("清空所有数据", role: .destructive) {
                    viewModel.clearAllData()
                }
                Button("仅清空已取件", role: .destructive) {
                    viewModel.clearCollectedData()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("确定要清空数据吗？此操作不可恢复。")
            }
            .alert("提示", isPresented: $viewModel.showClearResult) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(viewModel.clearResultMessage)
            }
        }
    }

    private func themeDisplayName(_ mode: String) -> String {
        switch mode {
        case "light": return "浅色模式"
        case "dark": return "深色模式"
        default: return "跟随系统"
        }
    }
}