import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var selectedPackage: ExpressPackage?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBar(text: $viewModel.searchText, placeholder: "搜索已取件记录")
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                if viewModel.filteredPackages.isEmpty {
                    EmptyStateView(
                        icon: "checkmark.circle",
                        title: "暂无已取件记录",
                        subtitle: "取件后的快递会出现在这里"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredPackages) { pkg in
                                PackageCard(package: pkg, showCollectedTime: true)
                                    .onTapGesture {
                                        selectedPackage = pkg
                                    }
                            }
                        }
                        .padding(16)
                    }
                    .refreshable {
                        viewModel.refresh()
                    }
                }
            }
            .navigationTitle("已取件")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !viewModel.collectedPackages.isEmpty {
                        Menu {
                            Button("清空已取件记录", role: .destructive) {
                                viewModel.clearAll()
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .sheet(item: $selectedPackage) { pkg in
                DetailView(package: pkg, readOnly: true) {
                    viewModel.refresh()
                }
            }
        }
    }
}