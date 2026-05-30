import SwiftUI

struct AddPackageView: View {
    @StateObject private var viewModel = AddPackageViewModel()
    @Environment(\.dismiss) private var dismiss
    var onSaved: (() -> Void)?

    var body: some View {
        NavigationStack {
            Form {
                // SMS import section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("从短信识别")
                            .font(.headline)

                        TextEditor(text: $viewModel.smsText)
                            .frame(minHeight: 80)

                        Button(action: {
                            viewModel.parseFromSms()
                        }) {
                            Label("识别取件码", systemImage: "text.magnifyingglass")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                } header: {
                    Text("短信识别")
                } footer: {
                    Text("粘贴快递短信内容，自动提取取件码、快递公司等信息")
                }

                // Manual input section
                Section("取件码信息") {
                    HStack {
                        Text("取件码")
                            .frame(width: 70, alignment: .leading)
                        TextField("必填", text: $viewModel.pickupCode)
                            .textFieldStyle(.plain)
                    }

                    HStack {
                        Text("快递公司")
                            .frame(width: 70, alignment: .leading)
                        TextField("选填", text: $viewModel.company)
                            .textFieldStyle(.plain)
                    }

                    HStack {
                        Text("取件地址")
                            .frame(width: 70, alignment: .leading)
                        TextField("选填", text: $viewModel.address)
                            .textFieldStyle(.plain)
                    }
                }

                Section("其他信息") {
                    HStack {
                        Text("柜号")
                            .frame(width: 70, alignment: .leading)
                        TextField("选填", text: $viewModel.cabinetNumber)
                            .textFieldStyle(.plain)
                    }

                    HStack {
                        Text("快递员电话")
                            .frame(width: 70, alignment: .leading)
                        TextField("选填", text: $viewModel.courierPhone)
                            .textFieldStyle(.plain)
                            .keyboardType(.phonePad)
                    }

                    HStack {
                        Text("运单号")
                            .frame(width: 70, alignment: .leading)
                        TextField("选填", text: $viewModel.trackingNumber)
                            .textFieldStyle(.plain)
                    }

                    HStack {
                        Text("备注")
                            .frame(width: 70, alignment: .leading)
                        TextField("选填", text: $viewModel.remark)
                            .textFieldStyle(.plain)
                    }
                }
            }
            .navigationTitle("添加快递")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        viewModel.save()
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.isValid)
                }
            }
            .alert("提示", isPresented: $viewModel.showSuccess) {
                Button("确定") {
                    dismiss()
                    onSaved?()
                }
            } message: {
                Text("快递已添加")
            }
            .alert("错误", isPresented: $viewModel.showError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}