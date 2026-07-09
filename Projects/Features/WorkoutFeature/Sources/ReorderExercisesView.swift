import SwiftUI
import CoreKit
import DesignSystem

struct ReorderExercisesView: View {
    let session: WorkoutSession
    @Environment(\.dismiss) private var dismiss
    @State private var orderedEntries: [WorkoutExerciseEntry]

    init(session: WorkoutSession) {
        self.session = session
        _orderedEntries = State(initialValue: session.entries.sorted { $0.sortOrder < $1.sortOrder })
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(orderedEntries) { entry in
                    HStack(spacing: AppSpacing.medium) {
                        Text(entry.muscleGroup.displayName)
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(entry.muscleGroup.color.opacity(0.15), in: Capsule())
                            .foregroundStyle(entry.muscleGroup.color)
                        Text(entry.exerciseName)
                    }
                }
                .onMove { fromOffsets, toOffset in
                    orderedEntries.move(fromOffsets: fromOffsets, toOffset: toOffset)
                }
            }
            .environment(\.editMode, .constant(.active))
            .listStyle(.plain)
            .navigationTitle("トレーニング順序入替")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Button {
                    applyOrder()
                    dismiss()
                } label: {
                    Text("完了")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColor.brand, in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .padding(AppSpacing.medium)
                .background(.bar)
            }
        }
    }

    private func applyOrder() {
        for (index, entry) in orderedEntries.enumerated() {
            entry.sortOrder = index
        }
    }
}
