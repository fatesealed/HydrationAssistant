import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        Form {
            Section("提醒") {
                Stepper("稍后提醒：\(viewModel.snoozeMinutes) 分钟", value: $viewModel.snoozeMinutes, in: 10...45)
            }

            Section("说明") {
                Text("首版使用体重公式自动计算目标饮水量，并只在上班时段内提醒。")
                    .font(.footnote)
            }
        }
        .padding()
        .frame(width: 420, height: 220)
    }
}
