import SwiftUI
import AppKit
import HydrationAssistantDomain

struct MenuBarContentView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !viewModel.hasCompletedOnboarding {
                onboardingView
            } else {
                mainView
            }

            Divider()
            Button("打开设置") {
                openWindow(id: "settings")
                NSApp.activate(ignoringOtherApps: true)
            }
            Button("测试提示") {
                viewModel.sendTestNotification()
            }
            Button("退出") {
                NSApp.terminate(nil)
            }
        }
        .padding(12)
        .frame(width: 320)
    }

    private var onboardingView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("首次使用设置")
                .font(.headline)
            Text("请在设置窗口填写体重、年龄、杯子容量、性别和时间段。")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("打开设置窗口") {
                openWindow(id: "settings")
                NSApp.activate(ignoringOtherApps: true)
            }
            .buttonStyle(.borderedProminent)

            if let message = viewModel.actionMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
    }

    private var mainView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: viewModel.animalSymbol)
                    .font(.title2)
                Text(viewModel.animalText)
                    .font(.headline)
            }

            HStack {
                Text(viewModel.workStatusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(viewModel.isWorking ? "下班" : "上班") {
                    if viewModel.isWorking {
                        viewModel.endWorkday()
                    } else {
                        viewModel.startWorkday()
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            Text(viewModel.dailyPlanText)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(viewModel.progressText)
                .font(.subheadline)
            Text(viewModel.nextReminderText)
                .font(.caption)
                .foregroundStyle(.secondary)

            ProgressView(value: viewModel.store.progress)

            VStack(alignment: .leading, spacing: 6) {
                Text("喝水")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    Button("喝半杯水") { viewModel.drinkHalfCup() }
                    Button("喝一杯水") { viewModel.drinkOneCup() }
                }
                .disabled(!viewModel.isWorking)
            }

            HStack {
                Button("稍后提醒") { viewModel.snooze() }
                    .disabled(!viewModel.isWorking)
            }

            Text("上班时段提醒，午休免打扰；下班后不提醒")
                .font(.caption2)
                .foregroundStyle(.secondary)

            if let message = viewModel.actionMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
    }

}
