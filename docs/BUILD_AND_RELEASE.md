# 构建与发布

本文档面向开发者，说明如何本地构建、如何生成 `.dmg`，以及如何为他人分发做签名与公证。

## 1. 环境要求

- macOS
- Xcode 15+
- 命令行工具可用：`xcodebuild`、`hdiutil`

## 2. Debug 构建

适合本地调试：

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild \
  -project GoldPrice.xcodeproj \
  -scheme GoldPrice \
  -configuration Debug \
  -derivedDataPath ./.build/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  build
```

产物路径通常为：

```text
.build/DerivedData/Build/Products/Debug/GoldPrice.app
```

## 3. Release 构建

适合打包：

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild \
  -project GoldPrice.xcodeproj \
  -scheme GoldPrice \
  -configuration Release \
  -derivedDataPath ./.build/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  build
```

产物路径通常为：

```text
.build/DerivedData/Build/Products/Release/GoldPrice.app
```

## 4. 生成 `.dmg`

本地自用的最简打包方式：

```bash
mkdir -p ./.build/dmg-root
cp -R ./.build/DerivedData/Build/Products/Release/GoldPrice.app ./.build/dmg-root/
ln -s /Applications ./.build/dmg-root/Applications

hdiutil create \
  -volname "GoldPrice" \
  -srcfolder ./.build/dmg-root \
  -ov \
  -format UDZO \
  ./GoldPrice.dmg
```

生成后的安装包在：

```text
./GoldPrice.dmg
```

## 5. 发给别人安装

若你打算把应用发给其他 macOS 用户，仅有 `.dmg` 还不够。

建议流程：

1. 使用 `Developer ID Application` 对 `GoldPrice.app` 签名
2. 使用 `notarytool` 提交 notarization
3. 使用 `stapler` 将公证结果回填到 `app` 或 `dmg`

典型命令链：

```bash
xcodebuild archive ...
xcodebuild -exportArchive ...
hdiutil create ...
xcrun notarytool submit ...
xcrun stapler staple ...
```

## 6. 常见发布问题

### Widget 不显示

请检查：

- 主 app 和 widget extension 的签名 Team 是否一致
- bundle id 是否冲突
- 主 app 是否先成功运行过一次

### Gatekeeper 拦截

说明你当前发出去的是无签名或未公证版本。对外分发前请补齐签名和 notarization。

### 数据源失效

应用依赖第三方报价源。若 `Kitco` 页面结构变化，可能需要调整解析逻辑，优先检查：

- `Shared/GoldPriceService.swift`
- `Shared/GoldPriceModels.swift`

## 7. 建议的发布检查清单

- `Release` 构建通过
- 菜单栏面板可正常打开
- 详情窗口可正常显示
- `自动`、`Kitco`、`Gold API` 三种模式都验证过
- `RMB / 克` 正常显示
- Widget 能被系统识别
- 安装包可正常挂载
- 若对外分发，签名和 notarization 已完成
