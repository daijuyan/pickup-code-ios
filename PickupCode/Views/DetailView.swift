import SwiftUI

struct DetailView: View {
    let package: ExpressPackage
    var readOnly: Bool = false
    var onDismiss: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var showCopyToast = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Large pickup code
                    VStack(spacing: 8) {
                        Text("取件码")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(package.pickupCode)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)

                        Button(action: {
                            UIPasteboard.general.string = package.pickupCode
                            showCopyToast = true
                        }) {
                            Label("复制取件码", systemImage: "doc.on.doc")
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.orange.opacity(0.15))
                                .foregroundColor(.orange)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top, 20)

                    // Info section
                    VStack(spacing: 0) {
                        if !package.company.isEmpty {
                            InfoRow(icon: "building.2", label: "快递公司", value: package.company)
                        }
                        if !package.address.isEmpty {
                            InfoRow(icon: "mappin", label: "取件地址", value: package.address)
                        }
                        if !package.cabinetNumber.isEmpty {
                            InfoRow(icon: "lock.rectangle", label: "柜号", value: package.cabinetNumber)
                        }
                        if !package.courierPhone.isEmpty {
                            InfoRow(icon: "phone", label: "快递员电话", value: package.courierPhone)
                        }
                        if !package.trackingNumber.isEmpty {
                            InfoRow(icon: "barcode", label: "运单号", value: package.trackingNumber)
                        }
                        InfoRow(icon: "clock", label: "收到时间", value: DateFormatter.medium.string(from: package.receivedTime))
                        if let collected = package.collectedTime {
                            InfoRow(icon: "checkmark.circle", label: "取件时间", value: DateFormatter.medium.string(from: collected), valueColor: .green)
                        }
                        if !package.remark.isEmpty {
                            InfoRow(icon: "note.text", label: "备注", value: package.remark)
                        }
                    }
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.04), radius: 2, y: 1)

                    // Status
                    HStack {
                        StatusBadge(status: package.status)
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                }
                .padding(16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("快递详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") {
                        dismiss()
                        onDismiss?()
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if showCopyToast {
                    Text("已复制到剪贴板")
                        .font(.subheadline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation { showCopyToast = false }
                            }
                        }
                }
            }
        }
    }
}

private struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.orange)
                .frame(width: 24)

            Text(label)
                .font(.body)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.body)
                .foregroundColor(valueColor)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        Divider().padding(.leading, 52)
    }
}