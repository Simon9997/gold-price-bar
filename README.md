# GoldPrice for macOS

[English](README.md) | [简体中文](README.zh-CN.md)

`GoldPrice` is a native SwiftUI macOS menu bar app for tracking live international gold prices in `USD / OZ` and `RMB / g`, with a desktop widget and a dedicated detail window.

![Platform](https://img.shields.io/badge/platform-macOS%2014%2B-black)
![SwiftUI](https://img.shields.io/badge/built%20with-SwiftUI-gold)
![Widget](https://img.shields.io/badge/widget-supported-8a6a1f)

## Preview

### Dashboard

![Dashboard Preview](docs/assets/preview-dashboard.png)

### Menu Bar Panel

![Menu Bar Preview](docs/assets/preview-menubar.png)

## Features

- Persistent menu bar entry for quick price lookup
- Second-level refresh in the main app
- `USD / OZ` and `RMB / g` primary price display
- Manual source switching: `Auto`, `Kitco`, `Gold API`
- Detail window with a short-range price chart
- `systemSmall` and `systemMedium` desktop widgets
- Native SwiftUI implementation without third-party dependencies

## Requirements

- macOS 14 or later
- Xcode 15 or later
- Network access to public price sources

## Quick Start

1. Open `GoldPrice.xcodeproj` in Xcode.
2. Select the `GoldPrice` scheme.
3. In `Signing & Capabilities`, assign a Team for both `GoldPrice` and `GoldPriceWidgetExtension`.
4. If the default `com.example.*` bundle identifiers conflict, replace them with your own.
5. Choose `My Mac` as the run destination.
6. Press `Cmd + R`.

After the first launch, the main entry lives in the macOS menu bar. Click the live price item to open the panel, then use `Detail` to open the full window.

## Documentation

- [Usage Guide](docs/USAGE.md)
- [Build and Release](docs/BUILD_AND_RELEASE.md)
- [Contributing](CONTRIBUTING.md)

Chinese versions:

- [使用手册](docs/USAGE.zh-CN.md)
- [构建与发布](docs/BUILD_AND_RELEASE.zh-CN.md)
- [贡献指南](CONTRIBUTING.zh-CN.md)

## Data Sources

The app currently supports the following modes:

- `Auto`: prefers `Kitco`, falls back to `Gold API`
- `Kitco`: parses live data directly from the Kitco chart page
- `Gold API`: uses `https://api.gold-api.com/price/XAU`

`RMB / g` is calculated from `USD/CNY` data parsed alongside the quote source. If exchange-rate parsing fails, the RMB price is shown as `--`.

## Refresh Policy

- Menu bar panel and detail window: refresh every second
- Widget: refresh frequency is controlled by `WidgetKit`

That means true second-level updates only apply to the main app, not to the widget.

## Project Structure

```text
GoldPriceApp/
  GoldPriceApp.swift
  MenuBarViews.swift
  ContentView.swift
  GoldPriceViewModel.swift

GoldPriceWidget/
  GoldPriceWidget.swift

Shared/
  GoldPriceService.swift
  GoldPriceModels.swift
  Formatting.swift
  GoldPriceTheme.swift

docs/
  assets/
  USAGE.md
  USAGE.zh-CN.md
  BUILD_AND_RELEASE.md
  BUILD_AND_RELEASE.zh-CN.md

scripts/
  generate_app_icon.swift
  generate_icon_concepts.swift
  generate_readme_previews.swift
  render_menu_header_preview.swift
```

## Local Build

Unsigned local build:

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

- Widgets cannot refresh every second
- Price parsing depends on third-party page structure and public endpoints
- The repository does not include signing or notarization automation
- The repository does not currently include a `LICENSE`

## Contributing

Issues and pull requests are welcome. Read [Contributing](CONTRIBUTING.md) before making larger changes.

## License

No license file is included yet. If you plan to publish the repository publicly, define the license before release.
