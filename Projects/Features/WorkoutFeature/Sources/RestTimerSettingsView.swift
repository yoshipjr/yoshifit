import SwiftUI
import CoreKit
import DesignSystem

struct RestTimerSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isPopupEnabled = RestTimerSettingsStore.shared.isPopupEnabled
    @State private var isAlarmEnabled = RestTimerSettingsStore.shared.isAlarmSoundEnabled
    @State private var volume = RestTimerSettingsStore.shared.volume

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            HStack {
                Text("休憩タイマーの設定")
                    .font(.headline)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(AppColor.secondaryText)
                        .padding(10)
                        .background(AppColor.screenBackground, in: Circle())
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Toggle("拡大表示", isOn: $isPopupEnabled)
                    .tint(AppColor.brand)
                Text("セット完了時に休憩タイマーが起動する際ポップアップで拡大表示します")
                    .font(.caption)
                    .foregroundStyle(AppColor.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Toggle("アラーム音", isOn: $isAlarmEnabled)
                .tint(AppColor.brand)

            HStack {
                Image(systemName: "speaker.fill")
                    .foregroundStyle(AppColor.secondaryText)
                Slider(value: $volume, in: 0...1)
                    .tint(AppColor.brand)
                Image(systemName: "speaker.wave.3.fill")
                    .foregroundStyle(AppColor.secondaryText)
            }

            Button {
                RestTimerSettingsStore.shared.isPopupEnabled = isPopupEnabled
                RestTimerSettingsStore.shared.isAlarmSoundEnabled = isAlarmEnabled
                RestTimerSettingsStore.shared.volume = volume
                dismiss()
            } label: {
                Text("設定")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColor.brand, in: RoundedRectangle(cornerRadius: 14))
            }

            Button("キャンセル") { dismiss() }
                .frame(maxWidth: .infinity)
                .foregroundStyle(AppColor.secondaryText)

            Spacer(minLength: 0)
        }
        .padding(AppSpacing.large)
        .presentationDetents([.height(420)])
        .presentationDragIndicator(.visible)
    }
}
