import SwiftUI

@main
struct HydrationAssistantApp: App {
    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {
        MenuBarExtra("喝水小助手", systemImage: "drop.circle") {
            MenuBarContentView(viewModel: viewModel)
        }

        Window("设置", id: "settings") {
            SettingsView(viewModel: viewModel)
        }
    }
}
