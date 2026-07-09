import SwiftUI
import SwiftData
import CoreKit
import DesignSystem

public struct ExercisePickerView: View {
    @Query(sort: \Exercise.sortOrder) private var exercises: [Exercise]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedGroup: MuscleGroup = .chest
    @State private var searchText = ""
    @State private var selectedIDs: Set<PersistentIdentifier> = []

    let onAdd: ([WorkoutExerciseEntry]) -> Void

    public init(onAdd: @escaping ([WorkoutExerciseEntry]) -> Void) {
        self.onAdd = onAdd
    }

    private var filtered: [Exercise] {
        exercises
            .filter { $0.muscleGroup == selectedGroup }
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundStyle(AppColor.secondaryText)
                    TextField("メニューを検索", text: $searchText)
                }
                .padding(AppSpacing.small)
                .background(AppColor.screenBackground, in: RoundedRectangle(cornerRadius: 12))
                .padding(AppSpacing.medium)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.large) {
                        ForEach(MuscleGroup.allCases) { group in
                            Button {
                                selectedGroup = group
                            } label: {
                                Text(group.displayName)
                                    .fontWeight(selectedGroup == group ? .bold : .regular)
                                    .foregroundStyle(selectedGroup == group ? group.color : AppColor.secondaryText)
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.medium)
                }
                .padding(.bottom, AppSpacing.small)

                List(filtered) { exercise in
                    Button {
                        toggle(exercise)
                    } label: {
                        HStack {
                            Image(systemName: selectedIDs.contains(exercise.persistentModelID) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedIDs.contains(exercise.persistentModelID) ? AppColor.brand : AppColor.secondaryText)
                            Text(exercise.name).foregroundStyle(.primary)
                            Spacer()
                            if exercise.isFavorite {
                                Image(systemName: "star.fill").foregroundStyle(.yellow).font(.caption)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
            .navigationTitle("種目を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加 (\(selectedIDs.count))") { addSelected() }
                        .disabled(selectedIDs.isEmpty)
                }
            }
        }
    }

    private func toggle(_ exercise: Exercise) {
        if selectedIDs.contains(exercise.persistentModelID) {
            selectedIDs.remove(exercise.persistentModelID)
        } else {
            selectedIDs.insert(exercise.persistentModelID)
        }
    }

    private func addSelected() {
        let selected = exercises.filter { selectedIDs.contains($0.persistentModelID) }
        let entries = selected.enumerated().map { index, exercise in
            WorkoutExerciseEntry(
                exerciseName: exercise.name,
                muscleGroup: exercise.muscleGroup,
                sortOrder: index,
                sets: [SetEntry(weight: 0, reps: 0, sortOrder: 0)]
            )
        }
        entries.forEach { modelContext.insert($0) }
        onAdd(entries)
    }
}
