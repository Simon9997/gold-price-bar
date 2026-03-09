# GoldPrice for macOS

`GoldPrice` 是一个原生 SwiftUI macOS 菜单栏应用，用来实时查看国际金价，并支持桌面小组件。

应用主界面聚焦三个核心目标：

- 在菜单栏里快速看报价
- 在详情窗口里看更完整的价格信息和短时走势
- 在桌面小组件里低频查看当前金价

## Features

- 菜单栏常驻入口，点击后展开价格面板
- 主应用每秒刷新一次报价
- 支持 `USD / OZ` 和 `RMB / 克` 两种主显示
- 支持手动切换数据源：`自动`、`Kitco`、`Gold API`
- 提供详情窗口，展示最近 4 分钟价格走势
- 提供 `systemSmall` 和 `systemMedium` 两种 Widget
- 原生 macOS SwiftUI 实现，无第三方依赖

## Requirements

- macOS 14 或更高版本
- Xcode 15 或更高版本
- 可正常访问外部报价源

## Quick Start

1. 用 Xcode 打开 `GoldPrice.xcodeproj`
2. 选择 `GoldPrice` scheme
3. 在 `Signing & Capabilities` 中分别为 `GoldPrice` 和 `GoldPriceWidgetExtension` 选择你的 Team
4. 如果默认 `com.example.*` bundle id 冲突，改成你自己的 bundle id
5. 运行目标选择 `My Mac`
6. 按 `Cmd + R` 启动

首次运行后，应用主入口在菜单栏。点击菜单栏中的价格即可展开面板，点击 `详情` 可打开主窗口。

## Documentation

- [使用手册](docs/USAGE.md)
- [构建与发布](docs/BUILD_AND_RELEASE.md)
- [贡献指南](CONTRIBUTING.md)

## Data Sources

应用目前支持以下报价源：

- `自动`：优先使用 `Kitco`，失败时回退到 `Gold API`
- `Kitco`：直接抓取 Kitco 图表页中的实时数据
- `Gold API`：使用 `https://api.gold-api.com/price/XAU`

汇率换算使用 Kitco 页面中的 `USD/CNY` 数据。若汇率未成功获取，人民币价格会显示为 `--`。

## Refresh Policy

- 菜单栏面板和详情窗口：每秒刷新一次
- Widget：由 `WidgetKit` 控制刷新频率，成功时约 15 分钟后刷新，失败时约 5 分钟后重试

这意味着“秒级实时”只适用于主应用，不适用于 Widget。

## Project Structure

```text
GoldPriceApp/
  GoldPriceApp.swift            App 入口
  MenuBarViews.swift            菜单栏面板
  ContentView.swift             详情窗口
  GoldPriceViewModel.swift      刷新与状态管理

GoldPriceWidget/
  GoldPriceWidget.swift         Widget 视图与时间线

Shared/
  GoldPriceService.swift        数据抓取与源切换
  GoldPriceModels.swift         模型与数据源定义
  Formatting.swift              数值格式化
  GoldPriceTheme.swift          共用主题与像素风组件

docs/
  USAGE.md
  BUILD_AND_RELEASE.md

scripts/
  generate_app_icon.swift
  generate_icon_concepts.swift
  render_menu_header_preview.swift
```

## Local Build

无签名本地构建：

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

## Known Limitations

- Widget 无法实现每秒刷新
- 价格源依赖外部网页结构和公开接口，第三方变更可能导致解析失败
- 当前仓库未附带代码签名与 notarization 配置
- 当前仓库未指定开源许可证

## Contributing

欢迎提交 Issue 或 Pull Request。开始前建议先阅读 [贡献指南](CONTRIBUTING.md)。

## License

当前仓库尚未附带 `LICENSE` 文件。若你计划公开发布，请先明确许可证类型。
