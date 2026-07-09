import SwiftUI
import CoreKit
import DesignSystem

struct AddExerciseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var muscleGroup: MuscleGroup = .chest

    let onSave: (String, MuscleGroup) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("種目名") {
                    TextField("例: ダンベルカール", text: $name)
                }
                Section("部位") {
                    Picker("部位", selection: $muscleGroup) {
                        ForEach(MuscleGroup.allCases) { group in
                            Text(group.displayName).tag(group)
                        }
                    }
                    .pickerStyle(.wheel)
                }
            }
            .navigationTitle("種目を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        onSave(name, muscleGroup)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
