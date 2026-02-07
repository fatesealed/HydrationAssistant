import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: viewModel.animalSymbol)
                    .font(.title2)
                Text(viewModel.animalText)
                    .font(.headline)
            }

            Text(viewModel.progressText)
                .font(.subheadline)
            Text(viewModel.cupText)
                .font(.caption)
                .foregroundStyle(.secondary)

            ProgressView(value: viewModel.store.progress)

            HStack {
                Button("半杯") { viewModel.drinkHalfCup() }
                Button("一杯") { viewModel.drinkOneCup() }
            }

            HStack {
                Button("已接满") { viewModel.refillCup() }
                Button("稍后") { viewModel.snooze() }
            }

            Divider()
            Text("上班时段提醒，午休免打扰")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(width: 260)
    }
}
