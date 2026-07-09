import SwiftUI
import CoreKit
import DesignSystem

public struct BodyRecordEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var date: Date
    @State private var weightText = ""
    @State private var bodyFatText = ""
    @State private var muscleMassText = ""
    @State private var phase: TrainingPhase?

    public init(date: Date = Date()) {
        _date = State(initialValue: date)
    }

    private var canSave: Bool {
        !weightText.isEmpty || !bodyFatText.isEmpty || !muscleMassText.isEmpty
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("記録時間", selection: $date)
                }
                Section {
                    LabeledContent("体重") {
                        TextField("入力してください", text: $weightText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("体脂肪率") {
                        TextField("入力してください", text: $bodyFatText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("筋肉量") {
                        TextField("入力してください", text: $muscleMassText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                Section("フェーズ") {
                    HStack {
                        ForEach(TrainingPhase.allCases) { option in
                            Button {
                                phase = (phase == option) ? nil : option
                            } label: {
                                Text("\(option.shortLabel) \(option.displayName)")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppSpacing.small)
                                    .background(
                                        phase == option ? AppColor.brand.opacity(0.2) : AppColor.screenBackground,
                                        in: RoundedRectangle(cornerRadius: 10)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("カラダ記録を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存する") {
                        save()
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private func save() {
        let record = BodyRecord(
            date: date,
            weight: Double(weightText),
            bodyFatPercentage: Double(bodyFatText),
            muscleMass: Double(muscleMassText),
            phase: phase
        )
        modelContext.insert(record)
    }
}

#Preview {
    BodyRecordEditorView()
        .modelContainer(PersistenceController.makeContainer(inMemory: true))
}
