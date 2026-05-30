import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showAddSheet = false
    @State private var selectedPackage: ExpressPackage?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBar(text: $viewModel.searchText, placeholder: "搜索取件码、快递公司、地址")
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                if viewModel.filteredPackages.isEmpty {
                    EmptyStateView(
                        icon: "shippingbox",
                        title: "暂无待取件快递",
                        subtitle: "点击右下角 + 手动添加\n或从短信中识别取件码"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredPackages) { pkg in
                                PackageCard(package: pkg) {
                                    viewModel.markAsCollected(pkg)
                                }
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
            .navigationTitle("待取件")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddPackageView {
                    viewModel.refresh()
                }
            }
            .sheet(item: $selectedPackage) { pkg in
                DetailView(package: pkg) {
                    viewModel.refresh()
                }
            }
            .onAppear {
                StorageService.shared.syncFromNotificationExtension()
                viewModel.refresh()
            }
        }
    }
}