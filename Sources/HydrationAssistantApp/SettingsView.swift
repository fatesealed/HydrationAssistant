import SwiftUI
import HydrationAssistantDomain

struct SettingsView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                GroupBox("每日目标方式") {
                    VStack(alignment: .leading, spacing: 10) {
                        Picker("目标方式", selection: $viewModel.targetMode) {
                            Text("自动计算").tag(AppViewModel.TargetMode.auto)
                            Text("手动输入").tag(AppViewModel.TargetMode.manual)
                        }
                        .pickerStyle(.segmented)

                        if viewModel.targetMode == .manual {
                            row(label: "每日目标 (ml)", text: $viewModel.manualTargetInput)
                            Text("示例：2200")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("自动模式会使用体重、性别、年龄估算每日目标。")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 6)
                }

                GroupBox("个人信息") {
                    VStack(spacing: 10) {
                        row(label: "体重 (kg)", text: $viewModel.weightInput)
                        row(label: "年龄 (岁)", text: $viewModel.ageInput)
                        row(label: "杯子容量 (ml)", text: $viewModel.cupCapacityInput)

                        Picker("性别", selection: $viewModel.gender) {
                            Text("女").tag(Gender.female)
                            Text("男").tag(Gender.male)
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(.top, 6)
                }

                GroupBox("工作时段") {
                    VStack(spacing: 10) {
                        DatePicker("上班时间", selection: $viewModel.workStartTime, displayedComponents: .hourAndMinute)
                        DatePicker("下班时间", selection: $viewModel.workEndTime, displayedComponents: .hourAndMinute)
                        DatePicker("午休开始", selection: $viewModel.lunchStartTime, displayedComponents: .hourAndMinute)
                        DatePicker("午休结束", selection: $viewModel.lunchEndTime, displayedComponents: .hourAndMinute)
                    }
                    .padding(.top, 6)
                }

                GroupBox("提醒设置") {
                    Stepper("稍后提醒：\(viewModel.snoozeMinutes) 分钟", value: $viewModel.snoozeMinutes, in: 10...45)
                        .padding(.top, 6)
                }

                HStack(spacing: 10) {
                    Button("保存设置") {
                        viewModel.applySettings()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("重置设置") {
                        viewModel.resetSettings()
                    }
                    .foregroundStyle(.red)
                }

                if let message = viewModel.actionMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.green)
                }

                Text("首版使用体重公式自动计算目标饮水量，并只在上班时段内提醒。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .frame(width: 500, height: 500)
    }

    private func row(label: String, text: Binding<String>) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("", text: text)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
                .frame(width: 140)
        }
    }
}
