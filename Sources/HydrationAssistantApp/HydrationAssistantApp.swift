import SwiftUI

@main
struct HydrationAssistantApp: App {
    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {
        MenuBarExtra("喝水小助手", systemImage: "drop.circle") {
            MenuBarContentView(viewModel: viewModel)
        }

        Settings {
            SettingsView(viewModel: viewModel)
        }
    }
}
