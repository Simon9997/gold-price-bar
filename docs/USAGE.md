# Usage Guide

[English](USAGE.md) | [简体中文](USAGE.zh-CN.md)

This guide is for end users. It explains how to run `GoldPrice`, switch quote sources, and add the desktop widget.

## 1. Launch the App

### Run with Xcode

1. Open `GoldPrice.xcodeproj`.
2. Select the `GoldPrice` scheme.
3. Assign a signing Team for `GoldPrice` and `GoldPriceWidgetExtension`.
4. Run on `My Mac`.

### Run from a `.dmg`

1. Double-click `GoldPrice.dmg`.
2. Drag `GoldPrice.app` into `Applications`.
3. If macOS blocks the first launch, allow it in `System Settings > Privacy & Security`.

## 2. Menu Bar Panel

After launch, the main entry lives in the menu bar.

Clicking the live price item opens the panel. The panel typically shows:

- current `USD / OZ`
- current `RMB / g`
- last update time
- current session move
- source switcher buttons
- `Detail`, `Refresh`, and `Quit` actions

## 3. Source Switching

The menu bar panel supports three modes:

- `Auto`
  - default mode
  - prefers `Kitco`
  - automatically falls back to `Gold API`
- `Kitco`
  - forces Kitco only
  - fails directly if the Kitco page changes or becomes unreachable
- `Gold API`
  - forces `api.gold-api.com`

After switching source:

- the current history buffer is cleared and sampled again
- the app immediately sends a new request
- your selection is kept for the current run

## 4. Price Notes

The app focuses on two prices:

- `USD / OZ`
  - US dollar quote per troy ounce
- `RMB / g`
  - converted Chinese yuan price per gram

If the RMB price shows `--`, the current request did not provide a valid `USD/CNY` rate.

## 5. Detail Window

Click `Detail` in the menu bar panel to open the main window.

The detail window provides:

- a larger primary quote display
- a short-range price chart
- current session movement
- current source and last update time

The main app refreshes once per second, so the detail window is more real-time than the widget.

## 6. Add the Desktop Widget

Make sure the main app has launched successfully at least once before adding the widget.

### Method A: Desktop Context Menu

1. Right-click an empty area on the macOS desktop.
2. Choose `Edit Widgets`.
3. Search for `GoldPrice` or `国际金价`.
4. Choose `small` or `medium`.
5. Add it.

### Method B: Notification Center

1. Open Notification Center.
2. Scroll to the bottom.
3. Click `Edit Widgets`.
4. Search for and add `GoldPrice`.

## 7. Widget Refresh

Widgets are not second-level real-time.

Current behavior:

- normally refreshes again in about 15 minutes
- retries in about 5 minutes after a failed request

That is a normal `WidgetKit` limitation, not an app bug.

## 8. FAQ

### Q: Why does `Kitco` mode fail?

Possible reasons:

- Kitco changed the page structure
- network access failed
- a temporary timeout happened

Try switching back to `Auto` or directly to `Gold API`.

### Q: Why can't I see the widget?

Check the following:

- the main app has been launched at least once
- `GoldPriceWidgetExtension` is signed successfully
- both targets use the same Team
- the bundle identifiers do not conflict

### Q: Why isn't the price updating?

Check the following:

- your network connection
- whether the current source is reachable
- whether you are switching sources too frequently

You can also click `Refresh` in the menu bar panel to fetch immediately.

### Q: Why can't I just send this app to someone else?

Unsigned local builds are usually only suitable for your own Mac. To distribute it, you still need:

- Developer ID signing
- notarization
- stapling

See [Build and Release](BUILD_AND_RELEASE.md) for details.
