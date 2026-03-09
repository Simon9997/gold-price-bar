import AppKit
import SwiftUI

@MainActor
final class DashboardWindowController: NSObject, ObservableObject, NSWindowDelegate {
    private var window: NSWindow?

    func show(with viewModel: GoldPriceViewModel) {
        if window == nil {
            let controller = NSHostingController(rootView: ContentView(viewModel: viewModel))
            let window = NSWindow(contentViewController: controller)
            window.title = "国际金价"
            window.setContentSize(NSSize(width: 980, height: 720))
            window.minSize = NSSize(width: 760, height: 680)
            window.isReleasedWhenClosed = false
            window.collectionBehavior = [.moveToActiveSpace]
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true
            window.toolbarStyle = .unifiedCompact
            window.delegate = self
            self.window = window
            window.center()
        }

        if let controller = window?.contentViewController as? NSHostingController<ContentView> {
            controller.rootView = ContentView(viewModel: viewModel)
        }

        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
