import AppKit
import SwiftUI

@main
struct GoldPriceApp: App {
    @StateObject private var viewModel = GoldPriceViewModel(autoStart: true)
    @StateObject private var dashboardWindowController = DashboardWindowController()

    var body: some Scene {
        MenuBarExtra {
            MenuBarPanelView(
                viewModel: viewModel,
                openDashboard: {
                    dashboardWindowController.show(with: viewModel)
                },
                quitApp: {
                    NSApp.terminate(nil)
                }
            )
        } label: {
            MenuBarLabelView(viewModel: viewModel)
        }
        .menuBarExtraStyle(.window)
    }
}
