import SwiftUI

struct ShortcutSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var showCopied = false

    private let steps = ShortcutService.shared.generateShortcutSteps()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)

                        Text("快捷指令自动识别")
                            .font(.title2.bold())

                        Text("通过系统快捷指令，自动从短信中提取取件码并同步到 App。配置一次，永久生效。")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)

                    // Quick copy buttons
                    VStack(spacing: 12) {
                        Text("快捷复制")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 12) {
                            CopyButton(title: "URL Scheme", value: "pickupcode://add?code=") {
                                showCopiedToast()
                            }
                            CopyButton(title: "正则表达式", value: "取件码[：:]?\s*(\d{4,8})") {
                                showCopiedToast()
                            }
                        }

                        CopyButton(title: "打开 URL（完整）", value: "pickupcode://add?code=[匹配结果]") {
                            showCopiedToast()
                        }
                    }
                    .padding(.horizontal)

                    // Steps
                    VStack(spacing: 0) {
                        Text("详细步骤")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 16)

                        ForEach(steps, id: \.step) { step in
                            StepCard(
                                step: step.step,
                                title: step.title,
                                detail: step.detail,
                                isActive: currentStep == step.step - 1
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    currentStep = step.step - 1
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Automation setup hint
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("重要提示")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading, spacing: 8) {
                            HintRow(text: "iOS 15+ 需在 设置 → 快捷指令 → 允许不受信任的快捷指令")
                            HintRow(text: "自动化触发条件选「收到信息」，关键词填：取件码、驿站、快递、包裹")
                            HintRow(text: "务必关闭「运行前询问」才能全自动运行")
                            HintRow(text: "配置完成后，收到快递短信会自动弹出 App 并添加取件码")
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.08))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Advanced: Import shortcut file
                    VStack(spacing: 12) {
                        Button(action: exportShortcut) {
                            Label("导出快捷指令模板文件", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange.opacity(0.15))
                                .foregroundColor(.orange)
                                .cornerRadius(12)
                        }

                        Text("导出 .shortcut 文件后，用「快捷指令」App 打开即可导入")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("快捷指令配置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
            .overlay(alignment: .bottom) {
                if showCopied {
                    Text("已复制到剪贴板")
                        .font(.subheadline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }

    private func showCopiedToast() {
        withAnimation { showCopied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { showCopied = false }
        }
    }

    private func exportShortcut() {
        guard let data = ShortcutService.shared.exportShortcutPlist() else { return }

        let tmpURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("快递取件码识别.shortcut")
        try? data.write(to: tmpURL)

        let vc = UIActivityViewController(
            activityItems: [tmpURL],
            applicationActivities: nil
        )

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(vc, animated: true)
        }
    }
}

// MARK: - Sub Views

private struct CopyButton: View {
    let title: String
    let value: String
    var onCopy: () -> Void

    var body: some View {
        Button(action: {
            UIPasteboard.general.string = value
            onCopy()
        }) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.caption2.monospaced())
                    .foregroundColor(.orange)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(Color.orange.opacity(0.08))
            .cornerRadius(8)
        }
    }
}

private struct StepCard: View {
    let step: Int
    let title: String
    let detail: String
    let isActive: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Step number
            Text("\(step)")
                .font(.caption.bold())
                .foregroundColor(isActive ? .white : .orange)
                .frame(width: 28, height: 28)
                .background(isActive ? Color.orange : Color.orange.opacity(0.15))
                .cornerRadius(14)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)

                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(12)
        .background(isActive ? Color.orange.opacity(0.06) : Color.clear)
        .cornerRadius(10)
    }
}

private struct HintRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.orange)
                .frame(width: 6, height: 6)
                .offset(y: 6)

            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}