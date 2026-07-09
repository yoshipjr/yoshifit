import SwiftUI
import CoreKit
import DesignSystem

struct WorkoutCompletionView: View {
    @Bindable var session: WorkoutSession
    @Environment(\.modelContext) private var modelContext
    let onDone: () -> Void

    @State private var isEditingDuration = false
    @State private var isEditingCalories = false
    @State private var durationText = ""
    @State private var caloriesText = ""

    private var dateTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd (E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: session.date)
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 220, height: 220)
                    .overlay(Circle().stroke(.black, lineWidth: 6))
                    .overlay {
                        VStack(spacing: 6) {
                            Text("WELL")
                                .font(.title.bold())
                            Text("DONE")
                                .font(.system(size: 36, weight: .heavy))
                            Image(systemName: "hand.thumbsup.fill")
                                .font(.title2)
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColor.brand)

            VStack(spacing: AppSpacing.medium) {
                Text(dateTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                editableRow(
                    label: "トレーニング時間",
                    intValue: session.durationMinutes,
                    unit: "分",
                    isEditing: $isEditingDuration,
                    text: $durationText
                ) {
                    if let value = Int(durationText) { session.durationMinutes = value }
                }

                editableRow(
                    label: "消費カロリー",
                    intValue: session.caloriesBurned,
                    unit: "kcal",
                    isEditing: $isEditingCalories,
                    text: $caloriesText
                ) {
                    if let value = Int(caloriesText) { session.caloriesBurned = value }
                }

                Button {
                    try? modelContext.save()
                    onDone()
                } label: {
                    Text("完了")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.black, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.top, AppSpacing.medium)
            }
            .padding(AppSpacing.large)
            .background(AppColor.brand)
        }
        .background(AppColor.brand)
        .ignoresSafeArea(edges: .top)
    }

    @ViewBuilder
    private func editableRow(
        label: String,
        intValue: Int,
        unit: String,
        isEditing: Binding<Bool>,
        text: Binding<String>,
        onCommit: @escaping () -> Void
    ) -> some View {
        HStack {
            Text(label)
            Spacer()
            if isEditing.wrappedValue {
                TextField("", text: text)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
            } else {
                Text("\(intValue)\(unit)")
                    .foregroundStyle(AppColor.brand)
                    .fontWeight(.bold)
            }
            Button {
                if isEditing.wrappedValue {
                    onCommit()
                } else {
                    text.wrappedValue = "\(intValue)"
                }
                isEditing.wrappedValue.toggle()
            } label: {
                Image(systemName: isEditing.wrappedValue ? "checkmark.circle.fill" : "pencil")
                    .foregroundStyle(AppColor.brand)
            }
        }
        .padding(AppSpacing.medium)
        .background(AppColor.screenBackground, in: RoundedRectangle(cornerRadius: 10))
    }
}
