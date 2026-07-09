import SwiftUI
import CoreKit
import DesignSystem

/// Read-only breakdown of a single day's training record, with a tap-through to the editable session.
public struct SessionSummaryView: View {
    let session: WorkoutSession
    @Environment(\.dismiss) private var dismiss

    public init(session: WorkoutSession) {
        self.session = session
    }

    public var body: some View {
        ScrollView {
            CardContainer {
                HStack {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .foregroundStyle(AppColor.brand)
                    Text("トレーニング記録")
                        .font(.headline)
                }

                HStack {
                    statColumn(label: "時間", value: "\(session.durationMinutes)", unit: "m")
                    Spacer()
                    statColumn(label: "種目数", value: "\(session.entries.count)", unit: "個")
                    Spacer()
                    statColumn(label: "消費カロリー", value: "0", unit: "kcal")
                }

                HStack {
                    Text("全体ボリューム").foregroundStyle(.primary)
                    Spacer()
                    Text("\(Int(session.totalVolume)) kg").fontWeight(.bold)
                }

                ForEach(session.entries.sorted(by: { $0.sortOrder < $1.sortOrder })) { entry in
                    entrySection(entry)
                }
            }
            .padding(AppSpacing.medium)
        }
        .background(AppColor.screenBackground)
        .navigationTitle(dateTitle)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            NavigationLink {
                SessionEditorView(session: session, completionLabel: "修正完了", onSessionDeleted: { dismiss() })
            } label: {
                Text("記録修正")
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.small)
                    .background(AppColor.brand, in: RoundedRectangle(cornerRadius: 10))
            }
            .padding(AppSpacing.medium)
            .background(.bar)
        }
    }

    private var dateTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: session.date)
    }

    private func statColumn(label: String, value: String, unit: String) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.caption).foregroundStyle(AppColor.secondaryText)
            (Text(value).font(.title3.bold()) + Text(" \(unit)").font(.caption))
        }
    }

    private func entrySection(_ entry: WorkoutExerciseEntry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Circle().fill(entry.muscleGroup.color).frame(width: 8, height: 8)
                Text(entry.exerciseName)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Spacer()
                Text("総VOL \(Int(entry.totalVolume))kg")
                    .font(.caption)
                    .foregroundStyle(AppColor.secondaryText)
            }
            ForEach(entry.sets.sorted(by: { $0.sortOrder < $1.sortOrder })) { set in
                HStack {
                    Text("\(set.sortOrder + 1)")
                        .frame(width: 20, alignment: .leading)
                        .foregroundStyle(AppColor.secondaryText)
                    Spacer()
                    Text("\(Int(set.weight))kg")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Text("\(set.reps)回")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Text(set.oneRepMax.map { "1RM:\(String(format: "%.2f", $0))kg" } ?? "")
                        .frame(width: 110, alignment: .trailing)
                        .foregroundStyle(AppColor.secondaryText)
                }
                .font(.subheadline)
                .foregroundStyle(.primary)
            }
        }
        .padding(.top, AppSpacing.small)
    }
}

#Preview {
    NavigationStack {
        SessionSummaryView(
            session: WorkoutSession(
                date: Date(),
                durationMinutes: 39,
                entries: [
                    WorkoutExerciseEntry(
                        exerciseName: "ダンベルベンチプレス",
                        muscleGroup: .chest,
                        sets: [SetEntry(weight: 28, reps: 7, sortOrder: 0)]
                    )
                ]
            )
        )
    }
}
