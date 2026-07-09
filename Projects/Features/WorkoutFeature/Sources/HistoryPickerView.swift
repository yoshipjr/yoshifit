import SwiftUI
import SwiftData
import CoreKit
import DesignSystem

public struct HistoryPickerView: View {
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var expandedSessionID: PersistentIdentifier?
    @State private var checkedEntryIDs: Set<PersistentIdentifier> = []

    let onLoad: ([WorkoutExerciseEntry]) -> Void

    public init(onLoad: @escaping ([WorkoutExerciseEntry]) -> Void) {
        self.onLoad = onLoad
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月 dd日 (E) HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("読み込むトレーニング履歴を選択してください")
                        .font(.headline)
                    Text("※選択した履歴の日付が新しい順でトレーニングメニューに追加されます")
                        .font(.footnote)
                        .foregroundStyle(AppColor.secondaryText)
                }

                ForEach(sessions) { session in
                    sessionSection(session)
                }
            }
            .navigationTitle("履歴から読み込む")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    load()
                } label: {
                    Text("読み込む")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColor.brand)
                .disabled(checkedEntryIDs.isEmpty)
                .padding(AppSpacing.medium)
                .background(.bar)
            }
        }
    }

    private func sessionSection(_ session: WorkoutSession) -> some View {
        DisclosureGroup(
            isExpanded: Binding(
                get: { expandedSessionID == session.persistentModelID },
                set: { expandedSessionID = $0 ? session.persistentModelID : nil }
            )
        ) {
            Button(allChecked(in: session) ? "チェックを外す" : "全てチェックする") {
                toggleAll(in: session)
            }
            .font(.subheadline.bold())
            .foregroundStyle(AppColor.brand)

            ForEach(session.entries.sorted(by: { $0.sortOrder < $1.sortOrder })) { entry in
                entryRow(entry)
            }
        } label: {
            HStack {
                Text(dateFormatter.string(from: session.date))
                ForEach(session.muscleGroups) { group in
                    Text(group.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(group.color.opacity(0.15), in: Capsule())
                        .foregroundStyle(group.color)
                }
            }
        }
    }

    private func entryRow(_ entry: WorkoutExerciseEntry) -> some View {
        Button {
            toggle(entry)
        } label: {
            HStack(alignment: .top) {
                Image(systemName: checkedEntryIDs.contains(entry.persistentModelID) ? "checkmark.square.fill" : "square")
                    .foregroundStyle(checkedEntryIDs.contains(entry.persistentModelID) ? AppColor.brand : AppColor.secondaryText)

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Circle().fill(entry.muscleGroup.color).frame(width: 6, height: 6)
                        Text(entry.exerciseName).foregroundStyle(.primary)
                    }
                    ForEach(entry.sets.sorted(by: { $0.sortOrder < $1.sortOrder })) { set in
                        Text("\(set.sortOrder + 1)セット \(Int(set.weight))kg \(set.reps)回")
                            .font(.caption)
                            .foregroundStyle(AppColor.secondaryText)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func allChecked(in session: WorkoutSession) -> Bool {
        let ids = session.entries.map(\.persistentModelID)
        return !ids.isEmpty && ids.allSatisfy(checkedEntryIDs.contains)
    }

    private func toggleAll(in session: WorkoutSession) {
        let ids = session.entries.map(\.persistentModelID)
        if allChecked(in: session) {
            ids.forEach { checkedEntryIDs.remove($0) }
        } else {
            ids.forEach { checkedEntryIDs.insert($0) }
        }
    }

    private func toggle(_ entry: WorkoutExerciseEntry) {
        if checkedEntryIDs.contains(entry.persistentModelID) {
            checkedEntryIDs.remove(entry.persistentModelID)
        } else {
            checkedEntryIDs.insert(entry.persistentModelID)
        }
    }

    private func load() {
        let selectedEntries = sessions
            .flatMap(\.entries)
            .filter { checkedEntryIDs.contains($0.persistentModelID) }

        let newEntries = selectedEntries.enumerated().map { index, entry -> WorkoutExerciseEntry in
            let copiedSets = entry.sets
                .sorted { $0.sortOrder < $1.sortOrder }
                .map { SetEntry(weight: $0.weight, reps: $0.reps, isCompleted: false, sortOrder: $0.sortOrder) }
            return WorkoutExerciseEntry(
                exerciseName: entry.exerciseName,
                muscleGroup: entry.muscleGroup,
                sortOrder: index,
                sets: copiedSets
            )
        }

        newEntries.forEach { modelContext.insert($0) }
        onLoad(newEntries)
    }
}
