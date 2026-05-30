import SwiftUI

struct PackageCard: View {
    let package: ExpressPackage
    var showCollectedTime: Bool = false
    var onCollect: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(package.pickupCode)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)

                Spacer()

                if package.status == .pending {
                    Button(action: { onCollect?() }) {
                        Text("取件")
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.15))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                    }
                }
            }

            if !package.company.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "building.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(package.company)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            if !package.address.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(package.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }

            HStack {
                Text(DateFormatter.shortDate.string(from: package.receivedTime))
                    .font(.caption)
                    .foregroundColor(.secondary)

                if showCollectedTime, let collected = package.collectedTime {
                    Text("取件: \(DateFormatter.shortDate.string(from: collected))")
                        .font(.caption)
                        .foregroundColor(.green)
                }

                Spacer()

                StatusBadge(status: package.status)
            }
        }
        .padding(16)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}