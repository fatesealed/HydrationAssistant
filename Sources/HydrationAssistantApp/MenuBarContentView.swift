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
            Text("请在设置窗口选择目标方式：自动计算（体重/性别/年龄）或手动输入每日饮水量。")
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
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.22))
                        .frame(width: 44, height: 44)
                    Image(systemName: viewModel.animalSymbol)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("喝水提醒")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                    Text(viewModel.animalText)
                        .font(.system(size: 27, weight: .heavy))
                        .minimumScaleFactor(0.78)
                        .lineLimit(2)
                        .foregroundStyle(.white)
                }
                Spacer(minLength: 0)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: bannerColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.20), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.16), radius: 8, x: 0, y: 4)

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

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("喝水进度")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(viewModel.store.progress * 100))%")
                        .font(.headline)
                        .fontWeight(.bold)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.20))
                            .frame(height: 16)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.19, green: 0.58, blue: 0.96),
                                        Color(red: 0.24, green: 0.75, blue: 0.52)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: max(12, geo.size.width * max(0.0, min(1.0, viewModel.store.progress))),
                                height: 16
                            )
                    }
                }
                .frame(height: 16)

                Text("当前 \(viewModel.store.state.consumedMl) ml / 目标 \(viewModel.store.state.targetMl) ml")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.black.opacity(0.04))
            )

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

    private var bannerColors: [Color] {
        if viewModel.animalText.contains("超前") {
            return [Color(red: 0.10, green: 0.57, blue: 0.31), Color(red: 0.16, green: 0.70, blue: 0.40)]
        }
        if viewModel.animalText.contains("稳定") {
            return [Color(red: 0.12, green: 0.45, blue: 0.82), Color(red: 0.19, green: 0.59, blue: 0.94)]
        }
        return [Color(red: 0.83, green: 0.35, blue: 0.17), Color(red: 0.95, green: 0.50, blue: 0.16)]
    }

}
