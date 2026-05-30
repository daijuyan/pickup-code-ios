# 快递取件码 iOS App

## 功能

- **待取件管理**：查看所有待取件快递，大号取件码显示
- **一键复制**：点击复制取件码到剪贴板
- **短信识别**：粘贴快递短信，自动提取取件码、快递公司、地址
- **通知拦截识别**：通过 Notification Service Extension 拦截推送通知，自动解析取件码
- **已取件归档**：标记取件后自动归档到历史记录
- **通知提醒**：新快递通知、取件超时提醒
- **主题切换**：浅色/深色/跟随系统
- **数据管理**：清空数据功能

## 支持的快递公司

菜鸟驿站、丰巢、妈妈驿站、兔喜生活、心愿智能柜、顺丰、中通、圆通、申通、韵达、京东、极兔、邮政EMS

## Xcode 项目配置

### 1. 创建项目

1. 打开 Xcode → File → New → Project
2. 选择 **iOS → App**
3. 配置：
   - Product Name: `PickupCode`
   - Team: 你的开发者账号
   - Organization Identifier: `com.codex`
   - Bundle Identifier 会自动设为 `com.codex.PickupCode`
   - Language: **Swift**
   - Interface: **SwiftUI**
   - **取消勾选** Include Tests
4. 保存到 `ios/PickupCode/`

### 2. 添加 App 主文件

删除 Xcode 自动生成的 `ContentView.swift` 和 `PickupCodeApp.swift`。

将 `PickupCode/PickupCode/` 目录下所有文件拖入 Xcode 项目（选择 **Copy items if needed** + **Create groups**）。

### 3. 配置 App Group（关键步骤）

**两个 target 都需要配置 App Group：**

#### 主 App Target:
1. 选择项目 → **PickupCode** target → **Signing & Capabilities**
2. 点击 **+ Capability** → 搜索并添加 **App Groups**
3. 点击 **+** 添加 group: `group.com.codex.pickupcode`
4. 勾选该 group

#### Notification Service Extension Target:
1. 选择 **PickupCodeNotificationService** target → **Signing & Capabilities**
2. 同样添加 **App Groups** capability
3. 添加同一个 group: `group.com.codex.pickupcode`
4. 勾选该 group

### 4. 添加 Notification Service Extension

1. File → New → Target
2. 搜索 **Notification Service Extension**
3. 配置：
   - Product Name: `PickupCodeNotificationService`
   - Language: **Swift**
   - 点击 **Finish**
4. 弹窗选择 **Activate**（激活该 scheme）
5. 删除 Xcode 自动生成的 `NotificationService.swift`
6. 将 `PickupCode/PickupCodeNotificationService/` 下的文件拖入该 target

### 5. 配置 Entitlements

确认两个 target 的 entitlements 文件都指向了正确的 `.entitlements`：
- 主 App: `PickupCode.entitlements`
- Extension: `PickupCodeNotificationService.entitlements`

在 Build Settings 中搜索 **Code Signing Entitlements**，确认路径正确。

### 6. 运行

1. 选择 **PickupCode** scheme（不是 NotificationService）
2. 选择模拟器或真机
3. Cmd + R 运行

## 使用万能签安装（重要）

如果你使用万能签（或类似工具）签名安装 IPA，出现白屏问题，请按以下步骤操作：

### 问题原因

1. **文件编码错误**：源代码中的中文字符串如果编码不正确，会导致编译失败或运行时崩溃
2. **App Groups 签名问题**：万能签会改变 Bundle Identifier，导致 App Groups entitlement 失效

### 解决方案

1. **确保源代码使用 UTF-8 编码**：所有 Swift 文件必须使用 UTF-8 编码保存
2. **App Groups 已做容错处理**：StorageService 已添加 App Group 可用性检测，即使签名后 App Group 不可用也不会崩溃
3. **使用正确的构建方式**：

#### 通过 Xcode 构建 IPA：

```bash
# 1. 清理项目
xcodebuild clean -project ios/PickupCode/PickupCode.xcodeproj -scheme PickupCode

# 2. 构建 Archive
xcodebuild archive \
  -project ios/PickupCode/PickupCode.xcodeproj \
  -scheme PickupCode \
  -archivePath build/PickupCode.xcarchive \
  -destination "generic/platform=iOS" \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO

# 3. 导出 IPA
xcodebuild -exportArchive \
  -archivePath build/PickupCode.xcarchive \
  -exportPath build/output \
  -exportOptionsPlist ExportOptions.plist
```

#### ExportOptions.plist 示例：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>manual</string>
</dict>
</plist>
```

#### 通过万能签安装：

1. 使用上述方法导出 IPA（或从 GitHub Actions 下载）
2. 打开万能签
3. 导入 IPA 文件
4. 签名并安装到设备

### 常见问题排查

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 白屏 | 源代码编码错误 | 确保所有 Swift 文件使用 UTF-8 编码 |
| 白屏 | JS Bundle 未嵌入（仅 Expo 版） | 使用 native Swift 版本而非 Expo 版 |
| 闪退 | App Groups 签名失效 | 已做容错处理，升级到最新代码 |
| 无法安装 | 签名证书问题 | 检查万能签证书是否有效 |
| 通知不工作 | Extension 未正确签名 | 使用主 App 功能，通知扩展需要完整签名 |

## 通知拦截识别原理

```
系统推送通知到达
    → Notification Service Extension 拦截
    → 解析通知文本，匹配快递关键词 + 取件码正则
    → 识别成功 → 修改通知标题（显示取件码）+ 保存到共享容器
    → App 回到前台 → 从共享容器同步数据 → 显示在待取件列表
```

**限制：**
- 只能拦截**推送通知**，无法读取历史短信或历史通知
- 需要 App 启用推送通知权限
- 部分 App 的通知可能不包含完整取件码信息
- 建议同时使用"手动添加"和"短信粘贴识别"作为补充

## 项目结构

```
PickupCode/
├── PickupCodeApp.swift              # App 入口
├── ContentView.swift                # TabView 主界面
├── Info.plist                       # 应用配置
├── PickupCode.entitlements          # App Group 权限
├── Models/
│   ├── ExpressPackage.swift         # 快递数据模型
│   └── PackageStatus.swift          # 状态枚举
├── ViewModels/
│   ├── HomeViewModel.swift          # 首页逻辑
│   ├── HistoryViewModel.swift       # 历史记录逻辑
│   ├── AddPackageViewModel.swift    # 添加快递逻辑
│   └── SettingsViewModel.swift      # 设置逻辑
├── Views/
│   ├── HomeView.swift               # 待取件列表
│   ├── HistoryView.swift            # 已取件列表
│   ├── DetailView.swift             # 快递详情
│   ├── AddPackageView.swift         # 添加快递表单
│   ├── SettingsView.swift           # 设置页面
│   └── Components/
│       ├── PackageCard.swift        # 快递卡片
│       ├── StatusBadge.swift        # 状态标签
│       ├── SearchBar.swift          # 搜索框
│       └── EmptyStateView.swift     # 空状态
├── Services/
│   ├── StorageService.swift         # 数据持久化 + App Group 同步
│   ├── NotificationService.swift    # 本地通知
│   └── SmsParser.swift              # 短信解析引擎
└── Utils/
    └── DateFormatter+Ext.swift      # 日期格式化
PickupCodeNotificationService/       # 通知服务扩展
├── NotificationService.swift        # 拦截通知 + 解析取件码
├── Info.plist
└── PickupCodeNotificationService.entitlements
```

## 使用流程

1. **首次启动**：App 会请求通知权限，请允许
2. **日常使用**：
   - 快递短信推送到达 → 通知扩展自动识别 → 通知标题显示取件码
   - 打开 App → 自动同步识别结果 → 待取件列表显示
   - 取件后点击"取件"按钮 → 归档到已取件
3. **手动添加**：点击 + 按钮，输入取件码或粘贴短信
4. **短信识别**：在添加页面粘贴短信内容，自动提取取件码

## 与 Android 版本差异

| 功能 | Android | iOS |
|------|---------|-----|
| 短信读取 | 直接读取系统短信数据库 | 不支持（Apple 限制） |
| 通知拦截 | 不需要（直接读短信） | Notification Service Extension |
| 后台监控 | ContentObserver + WorkManager | 通知扩展自动触发 |
| 数据存储 | Room (SQLite) | JSON 文件 |
| Root 扩展 | 支持（MIUI 等） | 不需要 |
| UI 框架 | Jetpack Compose | SwiftUI |