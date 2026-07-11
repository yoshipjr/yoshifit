import SwiftUI
import SwiftData
import UIKit
import AudioToolbox
import CoreKit
import DesignSystem

public struct SessionEditorView: View {
    @Bindable var session: WorkoutSession
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    private let viewModel = WorkoutViewModel()
    private let completionLabel: String

    @State private var isPresentingHistoryPicker = false
    @State private var isPresentingExercisePicker = false
    @State private var isPresentingActionMenu = false
    @State private var isPresentingReorder = false
    @State private var isPresentingDeleteConfirmation = false
    private let onSessionDeleted: (() -> Void)?

    // Live, same-day workout tracking.
    @State private var now = Date()
    @State private var restRemainingSeconds = 0
    @State private var isRestRunning = false
    @State private var isPresentingRestTimer = false
    @State private var isPresentingCompletion = false

    public init(session: WorkoutSession, completionLabel: String = "保存する", onSessionDeleted: (() -> Void)? = nil) {
        self.session = session
        self.completionLabel = completionLabel
        self.onSessionDeleted = onSessionDeleted
    }

    private var titleText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "ja_JP")
        return "\(formatter.string(from: session.date)) トレーニング"
    }

    /// Only a same-day, not-yet-finished session gets the live start/rest-timer flow.
    private var showsLiveWorkoutFlow: Bool {
        Calendar.current.isDateInToday(session.date) && session.finishedAt == nil
    }

    private var bottomBarLabel: String {
        session.finishedAt != nil ? "修正完了" : completionLabel
    }

    private var elapsedSeconds: Int {
        guard let startedAt = session.startedAt else { return 0 }
        return max(0, Int(now.timeIntervalSince(startedAt)))
    }

    private func timeLabel(_ totalSeconds: Int) -> String {
        String(format: "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
    }

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(session.entries.sorted(by: { $0.sortOrder < $1.sortOrder })) { entry in
                    ExerciseEntryCard(entry: entry, onDelete: { delete(entry) }, onSetCompleted: startRestTimer)
                    Divider()
                }
            }

            HStack(spacing: AppSpacing.small) {
                Button {
                    isPresentingHistoryPicker = true
                } label: {
                    Text("履歴から読み込む")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.small)
                }
                .buttonStyle(.bordered)

                Button {
                    isPresentingExercisePicker = true
                } label: {
                    Text("メニューを追加")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.small)
                        .background(.black, in: RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(AppSpacing.medium)
            .background(AppColor.screenBackground)
        }
        .background(AppColor.screenBackground)
        .scrollDismissesKeyboard(.immediately)
        .simultaneousGesture(TapGesture().onEnded { hideKeyboard() })
        .onSubmit { hideKeyboard() }
        .navigationTitle(titleText)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingActionMenu = true
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(.primary)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            tick()
        }
        .fullScreenCover(isPresented: $isPresentingCompletion) {
            WorkoutCompletionView(session: session) {
                isPresentingCompletion = false
            }
        }
        .sheet(isPresented: $isPresentingRestTimer) {
            RestTimerPopupView(remainingSeconds: $restRemainingSeconds) {
                restRemainingSeconds = 0
                isRestRunning = false
            }
        }
        .sheet(isPresented: $isPresentingHistoryPicker) {
            HistoryPickerView { entries in
                isPresentingHistoryPicker = false
                appendEntries(entries)
            }
        }
        .sheet(isPresented: $isPresentingExercisePicker) {
            ExercisePickerView { entries in
                isPresentingExercisePicker = false
                appendEntries(entries)
            }
        }
        .sheet(isPresented: $isPresentingActionMenu) {
            SessionActionMenuSheet(
                session: session,
                onReorder: { isPresentingReorder = true },
                onDeleteRequested: { isPresentingDeleteConfirmation = true }
            )
        }
        .sheet(isPresented: $isPresentingReorder) {
            ReorderExercisesView(session: session)
        }
        .alert("この記録を削除しますか？", isPresented: $isPresentingDeleteConfirmation) {
            Button("削除", role: .destructive) { deleteSession() }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("この操作は取り消せません。")
        }
    }

    private func deleteSession() {
        modelContext.delete(session)
        try? modelContext.save()
        if let onSessionDeleted {
            onSessionDeleted()
        } else {
            dismiss()
        }
    }

    private func appendEntries(_ entries: [WorkoutExerciseEntry]) {
        let startIndex = session.entries.count
        for (offset, entry) in entries.enumerated() {
            entry.sortOrder = startIndex + offset
        }
        session.entries.append(contentsOf: entries)
    }

    private func delete(_ entry: WorkoutExerciseEntry) {
        session.entries.removeAll { $0.persistentModelID == entry.persistentModelID }
        modelContext.delete(entry)
    }

    private func finish() {
        session.durationMinutes = max(session.durationMinutes, viewModel.elapsedMinutes(start: session.date))
        try? modelContext.save()
        dismiss()
    }

    @ViewBuilder
    private var bottomBar: some View {
        if showsLiveWorkoutFlow {
            if session.startedAt == nil {
                Button {
                    startWorkout()
                } label: {
                    Text("トレーニングを開始する")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColor.brand, in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .padding(AppSpacing.medium)
                .background(.bar)
            } else {
                HStack(spacing: 0) {
                    Button {
                        isPresentingRestTimer = true
                    } label: {
                        VStack(spacing: 2) {
                            Text(timeLabel(restRemainingSeconds))
                                .font(.subheadline.bold())
                            Text("休憩タイマー")
                                .font(.caption2)
                                .foregroundStyle(AppColor.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)

                    VStack(spacing: 2) {
                        Text(timeLabel(elapsedSeconds))
                            .font(.subheadline.bold())
                        Text("総時間")
                            .font(.caption2)
                            .foregroundStyle(AppColor.secondaryText)
                    }
                    .frame(maxWidth: .infinity)

                    Button {
                        finishWorkout()
                    } label: {
                        Text("終了")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, AppSpacing.large)
                            .padding(.vertical, AppSpacing.small)
                            .background(AppColor.brand, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
                .padding(AppSpacing.medium)
                .background(.bar)
            }
        } else {
            Button {
                finish()
            } label: {
                Text(bottomBarLabel)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.black, in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .padding(AppSpacing.medium)
            .background(.bar)
        }
    }

    private func startWorkout() {
        session.startedAt = Date()
        try? modelContext.save()
    }

    private func finishWorkout() {
        session.finishedAt = Date()
        session.durationMinutes = max(session.durationMinutes, elapsedSeconds / 60)
        try? modelContext.save()
        isPresentingCompletion = true
    }

    private func startRestTimer() {
        guard showsLiveWorkoutFlow, session.startedAt != nil else { return }
        restRemainingSeconds = 60
        isRestRunning = true
        if RestTimerSettingsStore.shared.isPopupEnabled {
            isPresentingRestTimer = true
        }
    }

    private func tick() {
        now = Date()
        guard isRestRunning else { return }
        if restRemainingSeconds > 0 {
            restRemainingSeconds -= 1
        }
        if restRemainingSeconds == 0 {
            isRestRunning = false
            if RestTimerSettingsStore.shared.isAlarmSoundEnabled {
                AudioServicesPlaySystemSound(SystemSoundID(1005))
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

private struct ExerciseEntryCard: View {
    @Bindable var entry: WorkoutExerciseEntry
    @Environment(\.modelContext) private var modelContext
    let onDelete: () -> Void
    let onSetCompleted: () -> Void
    private let viewModel = WorkoutViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundStyle(AppColor.secondaryText)
                Text(entry.muscleGroup.displayName)
                    .font(.caption2.bold())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(entry.muscleGroup.color.opacity(0.15), in: Capsule())
                    .foregroundStyle(entry.muscleGroup.color)
                Text(entry.exerciseName)
                    .font(.headline)
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(AppColor.secondaryText)
                }
            }

            TextField("メモを入力", text: $entry.memo)
                .submitLabel(.done)
                .padding(AppSpacing.small)
                .background(AppColor.screenBackground, in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColor.secondaryText.opacity(0.35), lineWidth: 1)
                )

            HStack {
                Text("セット").frame(width: 40, alignment: .leading)
                Text("kg").frame(maxWidth: .infinity)
                Text("回").frame(maxWidth: .infinity)
                Text("完了").frame(width: 50)
            }
            .font(.caption)
            .foregroundStyle(AppColor.secondaryText)

            ForEach(entry.sets.sorted(by: { $0.sortOrder < $1.sortOrder })) { set in
                SetRow(set: set, onCompleted: onSetCompleted)
            }

            HStack(spacing: AppSpacing.small) {
                Button {
                    removeLastSet()
                } label: {
                    Text("－ セット削除")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.small)
                }
                .buttonStyle(.bordered)
                .disabled(entry.sets.count <= 1)

                Button {
                    addSet()
                } label: {
                    Text("＋ セット追加")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.small)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(AppSpacing.medium)
    }

    private func addSet() {
        let next = viewModel.defaultNextSet(previousSets: entry.sets)
        let newSet = SetEntry(weight: next.weight, reps: next.reps, sortOrder: entry.sets.count)
        modelContext.insert(newSet)
        entry.sets.append(newSet)
    }

    private func removeLastSet() {
        guard let last = entry.sets.sorted(by: { $0.sortOrder < $1.sortOrder }).last else { return }
        entry.sets.removeAll { $0.persistentModelID == last.persistentModelID }
        modelContext.delete(last)
    }
}

private struct SetRow: View {
    @Bindable var set: SetEntry
    let onCompleted: () -> Void

    var body: some View {
        HStack {
            Text("\(set.sortOrder + 1)")
                .frame(width: 40, alignment: .leading)
                .foregroundStyle(AppColor.secondaryText)

            TextField("0", value: $set.weight, format: .number)
                .keyboardType(.decimalPad)
                .submitLabel(.done)
                .multilineTextAlignment(.center)
                .padding(6)
                .background(AppColor.screenBackground, in: RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppColor.secondaryText.opacity(0.35), lineWidth: 1)
                )
                .frame(maxWidth: .infinity)

            TextField("0", value: $set.reps, format: .number)
                .keyboardType(.numberPad)
                .submitLabel(.done)
                .multilineTextAlignment(.center)
                .padding(6)
                .background(AppColor.screenBackground, in: RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppColor.secondaryText.opacity(0.35), lineWidth: 1)
                )
                .frame(maxWidth: .infinity)

            Button {
                set.isCompleted.toggle()
                if set.isCompleted {
                    onCompleted()
                }
            } label: {
                Image(systemName: "checkmark")
                    .foregroundStyle(set.isCompleted ? .white : AppColor.secondaryText)
                    .frame(width: 32, height: 32)
                    .background(set.isCompleted ? AppColor.brand : AppColor.screenBackground, in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .frame(width: 50)
        }
        .padding(.vertical, 4)
    }
}

private struct SessionActionMenuSheet: View {
    let session: WorkoutSession
    let onReorder: () -> Void
    let onDeleteRequested: () -> Void
    @Environment(\.dismiss) private var dismiss

    private var dateTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd (E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: session.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(AppColor.secondaryText)
                        .padding(10)
                        .background(AppColor.screenBackground, in: Circle())
                }
            }

            Text(dateTitle)
                .font(.headline)

            Button {
                dismiss()
                onReorder()
            } label: {
                HStack(spacing: AppSpacing.medium) {
                    Image(systemName: "arrow.up.arrow.down")
                    Text("トレーニング順序入替")
                    Spacer()
                }
                .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)

            Button {
                dismiss()
                onDeleteRequested()
            } label: {
                HStack(spacing: AppSpacing.medium) {
                    Image(systemName: "trash")
                    Text("記録全体を削除")
                    Spacer()
                }
                .foregroundStyle(AppColor.danger)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(AppSpacing.large)
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.hidden)
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    let session = WorkoutSession(date: .now)
    let benchPress = WorkoutExerciseEntry(exerciseName: "ベンチプレス", muscleGroup: .chest, sortOrder: 0)
    benchPress.sets = [
        SetEntry(weight: 60, reps: 10, sortOrder: 0),
        SetEntry(weight: 65, reps: 8, sortOrder: 1),
    ]
    let squat = WorkoutExerciseEntry(exerciseName: "スクワット", muscleGroup: .legs, sortOrder: 1)
    squat.sets = [
        SetEntry(weight: 80, reps: 10, sortOrder: 0),
    ]
    session.entries = [benchPress, squat]
    container.mainContext.insert(session)

    return NavigationStack {
        SessionEditorView(session: session)
    }
    .modelContainer(container)
}
