import SwiftUI
import SwiftData
import CoreKit
import DesignSystem

/// The "記録" screen: lets the user add a body record or start a training record for `date`.
/// Used both as the Workout tab root (for today) and pushed from the calendar (for a past day).
public struct RecordEntryView: View {
    private let date: Date
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isPresentingBodyRecord = false
    @State private var isPresentingHistoryPicker = false
    @State private var isPresentingExercisePicker = false
    @State private var activeSession: WorkoutSession?

    public init(date: Date = Date()) {
        self.date = date
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.medium) {
                CardContainer {
                    HStack {
                        Image(systemName: "figure.mixed.cardio")
                            .foregroundStyle(AppColor.warning)
                        Text("カラダ記録")
                            .font(.headline)
                    }
                    Button {
                        isPresentingBodyRecord = true
                    } label: {
                        Text("カラダ記録を記録する")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.small)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColor.warning)
                }

                CardContainer {
                    HStack {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .foregroundStyle(AppColor.brand)
                        Text("トレーニング記録")
                            .font(.headline)
                    }
                    HStack(spacing: AppSpacing.small) {
                        Button {
                            isPresentingHistoryPicker = true
                        } label: {
                            Text("以前の履歴から選択")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.small)
                        }
                        .buttonStyle(.bordered)
                        .tint(AppColor.brand)

                        Button {
                            isPresentingExercisePicker = true
                        } label: {
                            Text("メニューから選択")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.small)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppColor.brand)
                    }
                }
            }
            .padding(AppSpacing.medium)
        }
        .background(AppColor.screenBackground)
        .navigationTitle("記録")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isPresentingBodyRecord) {
            BodyRecordEditorView(date: date)
        }
        .sheet(isPresented: $isPresentingHistoryPicker) {
            HistoryPickerView { entries in
                isPresentingHistoryPicker = false
                let session = WorkoutSession(date: date, entries: entries)
                modelContext.insert(session)
                activeSession = session
            }
        }
        .sheet(isPresented: $isPresentingExercisePicker) {
            ExercisePickerView { entries in
                isPresentingExercisePicker = false
                let session = WorkoutSession(date: date, entries: entries)
                modelContext.insert(session)
                activeSession = session
            }
        }
        .navigationDestination(item: $activeSession) { session in
            SessionEditorView(session: session, onSessionDeleted: { dismiss() })
        }
    }
}

#Preview {
    NavigationStack {
        RecordEntryView()
    }
    .modelContainer(PersistenceController.makeContainer(inMemory: true))
}
