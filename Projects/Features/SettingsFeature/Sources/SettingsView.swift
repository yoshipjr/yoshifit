import SwiftUI
import SwiftData
import CoreKit
import DesignSystem

public struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [WorkoutSession]
    @State private var viewModel = SettingsViewModel()
    @State private var targets: [MuscleGroup: Int] = [:]
    @State private var didSendTestNotification = false

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(AppColor.brand)
                        VStack(alignment: .leading) {
                            Text(AppBrand.displayName)
                                .font(.headline)
                            Text("トレーニングを記録しよう")
                                .font(.footnote)
                                .foregroundStyle(AppColor.secondaryText)
                        }
                    }
                    .padding(.vertical, AppSpacing.small)
                }

                Section("部位ごとの休息目標日数") {
                    ForEach(MuscleGroup.allCases) { group in
                        HStack {
                            Circle().fill(group.color).frame(width: 10, height: 10)
                            Text(group.displayName)
                            Spacer()
                            Stepper(
                                "\(targets[group, default: group.defaultRestDayTarget]) 日",
                                value: Binding(
                                    get: { targets[group, default: group.defaultRestDayTarget] },
                                    set: { newValue in
                                        targets[group] = newValue
                                        viewModel.setRestTarget(newValue, for: group)
                                        TrainingOverdueNotifier.reschedule(using: modelContext)
                                    }
                                ),
                                in: 1...14
                            )
                            .fixedSize()
                        }
                    }
                }

                Section {
                    LabeledContent("バージョン", value: "1.0.0")
                }

#if DEBUG
                Section("デバッグ") {
                    Button {
                        TrainingOverdueNotifier.sendTestNotification(sessions: sessions)
                        didSendTestNotification = true
                    } label: {
                        Text("超過通知をテスト送信（5秒後）")
                    }
                    if didSendTestNotification {
                        Text("送信しました。ホーム画面に戻って確認してください。")
                            .font(.caption)
                            .foregroundStyle(AppColor.secondaryText)
                    }
                }
#endif
            }
            .navigationTitle("設定")
        }
        .task {
            await viewModel.onAppear()
            for group in MuscleGroup.allCases {
                targets[group] = viewModel.restTarget(for: group)
            }
        }
    }
}

#Preview {
    SettingsView()
}
