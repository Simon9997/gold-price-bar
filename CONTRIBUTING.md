# Contributing

[English](CONTRIBUTING.md) | [简体中文](CONTRIBUTING.zh-CN.md)

Contributions to `GoldPrice` are welcome.

This is a compact native macOS SwiftUI app. Please keep the following principles in mind:

- prefer native implementation and avoid unnecessary dependencies
- keep the menu bar experience ahead of feature sprawl
- keep data presentation simple and readable
- keep documentation aligned with behavior

## Before You Start

1. Install Xcode 15 or later.
2. Open `GoldPrice.xcodeproj`.
3. Configure a local signing Team.
4. Make sure a `Debug` build works first.

## Good Contribution Areas

- quote source reliability
- parser robustness
- UI polish
- widget presentation
- documentation updates
- build and release improvements

## Pre-PR Checklist

Please verify at least the following:

- `Debug` build succeeds
- related documentation is updated
- the menu bar panel has no obvious layout regression
- if quote fetching changed, validate `Auto` and at least one fixed source
- if the widget changed, make sure the extension still builds

## Pull Request Notes

A good PR description should include:

- purpose of the change
- major implementation points
- manual verification steps
- known limits or remaining gaps

If the change affects UI, include screenshots when possible.

## Documentation Notes

The repository now keeps both English and Simplified Chinese documents. When you change behavior, update both sides if the change affects users or contributors.

Sync docs when you change:

- source behavior
- refresh policy
- widget limitations
- install or packaging flow
- distribution steps

## License

No license has been selected yet. Keep that in mind before contributing code intended for public release.
