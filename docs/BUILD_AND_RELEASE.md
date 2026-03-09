# Build and Release

[English](BUILD_AND_RELEASE.md) | [简体中文](BUILD_AND_RELEASE.zh-CN.md)

This guide is for developers. It covers local builds, `.dmg` packaging, and the extra steps needed for distribution.

## 1. Requirements

- macOS
- Xcode 15+
- command line tools available: `xcodebuild`, `hdiutil`

## 2. Debug Build

For local development:

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

Typical output:

```text
.build/DerivedData/Build/Products/Debug/GoldPrice.app
```

## 3. Release Build

For packaging:

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

Typical output:

```text
.build/DerivedData/Build/Products/Release/GoldPrice.app
```

## 4. Build a `.dmg`

Minimal local packaging flow:

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

Output:

```text
./GoldPrice.dmg
```

## 5. Distribute to Other Users

If you plan to send the app to other macOS users, a plain `.dmg` is not enough.

Recommended flow:

1. Sign `GoldPrice.app` with `Developer ID Application`
2. Submit with `notarytool`
3. Staple the notarization result back to the `app` or `dmg`

Typical command chain:

```bash
xcodebuild archive ...
xcodebuild -exportArchive ...
hdiutil create ...
xcrun notarytool submit ...
xcrun stapler staple ...
```

## 6. Common Release Issues

### Widget does not appear

Check:

- the main app and widget extension use the same Team
- the bundle identifiers do not conflict
- the main app has launched successfully at least once

### Gatekeeper blocks launch

This usually means the build is unsigned or not notarized. Complete signing and notarization before public distribution.

### Data source breaks

The app depends on third-party quote sources. If `Kitco` changes page structure, inspect:

- `Shared/GoldPriceService.swift`
- `Shared/GoldPriceModels.swift`

## 7. Suggested Release Checklist

- `Release` build succeeds
- menu bar panel opens correctly
- detail window shows correctly
- `Auto`, `Kitco`, and `Gold API` modes were all checked
- `RMB / g` displays correctly
- widget is recognized by the system
- the installer mounts correctly
- signing and notarization are complete if you are distributing publicly
