import SwiftUI
import CoreKit

public struct CircularRestGauge: View {
    private let muscleGroup: MuscleGroup
    private let status: RestStatus
    private let targetDays: Int

    public init(muscleGroup: MuscleGroup, status: RestStatus, targetDays: Int) {
        self.muscleGroup = muscleGroup
        self.status = status
        self.targetDays = targetDays
    }

    private var progress: Double {
        switch status {
        case .noHistory: 0
        case .overdue: 1
        case .remaining(let days):
            targetDays > 0 ? min(1, max(0, Double(targetDays - days) / Double(targetDays))) : 1
        }
    }

    private var ringColor: Color {
        switch status {
        case .noHistory: Color.gray.opacity(0.3)
        default: muscleGroup.color
        }
    }

    public var body: some View {
        VStack(spacing: AppSpacing.small) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                statusLabel
                    .multilineTextAlignment(.center)
            }
            .frame(width: 76, height: 76)

            Text(muscleGroup.displayName)
                .font(.subheadline.bold())
                .foregroundStyle(muscleGroup.color)
        }
    }

    @ViewBuilder
    private var statusLabel: some View {
        switch status {
        case .noHistory:
            Text("なし")
                .font(.subheadline.bold())
                .foregroundStyle(AppColor.secondaryText)
        case .remaining(let days):
            VStack(spacing: 0) {
                Text("あと")
                    .font(.caption2)
                    .foregroundStyle(AppColor.secondaryText)
                Text("\(days)").font(.title2.bold()) + Text("日").font(.caption)
            }
        case .overdue(let days):
            VStack(spacing: 0) {
                Text("超過")
                    .font(.caption2.bold())
                    .foregroundStyle(AppColor.danger)
                Text("\(days)").font(.title3.bold()).foregroundStyle(AppColor.danger)
                    + Text("日").font(.caption).foregroundStyle(AppColor.danger)
            }
        }
    }
}

#Preview {
    HStack {
        CircularRestGauge(muscleGroup: .chest, status: .remaining(4), targetDays: 4)
        CircularRestGauge(muscleGroup: .legs, status: .overdue(131), targetDays: 4)
        CircularRestGauge(muscleGroup: .abs, status: .noHistory, targetDays: 4)
    }
    .padding()
}
