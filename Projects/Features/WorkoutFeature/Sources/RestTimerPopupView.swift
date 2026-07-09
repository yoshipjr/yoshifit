import SwiftUI
import DesignSystem

struct RestTimerPopupView: View {
    @Binding var remainingSeconds: Int
    let onSkip: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isPresentingSettings = false

    private var timeLabel: String {
        String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
    }

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            HStack {
                Text("休憩タイマー")
                    .font(.headline)
                Spacer()
                Button { isPresentingSettings = true } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(AppColor.secondaryText)
                }
            }

            Text(timeLabel)
                .font(.system(size: 72, weight: .bold))
                .foregroundStyle(AppColor.brand)
                .monospacedDigit()
                .padding(.vertical, AppSpacing.large)

            HStack(spacing: AppSpacing.medium) {
                Button {
                    remainingSeconds = max(0, remainingSeconds - 10)
                } label: {
                    Text("-10秒")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.small)
                }
                .buttonStyle(.borderedProminent)
                .tint(.black)

                Button {
                    remainingSeconds += 10
                } label: {
                    Text("+10秒")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.small)
                }
                .buttonStyle(.borderedProminent)
                .tint(.black)
            }

            Spacer(minLength: 0)

            Divider()

            HStack(spacing: 0) {
                Button {
                    onSkip()
                    dismiss()
                } label: {
                    Text("スキップ")
                        .foregroundStyle(AppColor.danger)
                        .frame(maxWidth: .infinity)
                }
                Divider().frame(height: 24)
                Button {
                    dismiss()
                } label: {
                    Text("閉じる")
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(AppSpacing.large)
        .presentationDetents([.height(460)])
        .presentationDragIndicator(.hidden)
        .sheet(isPresented: $isPresentingSettings) {
            RestTimerSettingsView()
        }
    }
}
