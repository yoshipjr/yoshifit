import SwiftUI
import SwiftData
import CoreKit
import DesignSystem

public struct HomeView: View {
    @Query(sort: \BodyRecord.date, order: .reverse) private var bodyRecords: [BodyRecord]
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @State private var viewModel = HomeViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.medium) {
                    weightCard
                    weeklyGoalCard
                    restDayCard
                }
                .padding(AppSpacing.medium)
            }
            .background(AppColor.screenBackground)
            .safeAreaInset(edge: .top, spacing: 0) {
                BrandHeader(notificationCount: 6)
                    .background(AppColor.brand)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .task { await viewModel.onAppear() }
    }

    private var weightCard: some View {
        CardContainer {
            Text("体重")
                .font(.headline)
                .foregroundStyle(AppColor.warning)

            if let latest = bodyRecords.first(where: { $0.weight != nil }) {
                HStack(alignment: .firstTextBaseline) {
                    Text(latest.weight.map { String(format: "%.1f", $0) } ?? "--")
                        .font(.system(size: 40, weight: .bold))
                    Text("kg")
                        .foregroundStyle(AppColor.secondaryText)
                    Spacer()
                    Text(latest.date.formatted(date: .abbreviated, time: .omitted))
                        .foregroundStyle(AppColor.secondaryText)
                        .font(.footnote)
                }
            } else {
                VStack(spacing: AppSpacing.small) {
                    Text("記録が存在しません")
                        .font(.title3.bold())
                    Text("カラダ記録のグラフを\n確認するには記録してみましょう。")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppColor.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.large)
            }
        }
    }

    private var weeklyGoalCard: some View {
        let days = viewModel.weeklyMinutes(sessions: sessions)
        let total = days.reduce(0) { $0 + $1.minutes }
        return CardContainer {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("今週のトレーニング目標")
                        .font(.headline)
                        .foregroundStyle(.blue)
                    Text(viewModel.weekRangeLabel())
                        .font(.caption)
                        .foregroundStyle(AppColor.secondaryText)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    (Text("\(total)").font(.title.bold()) + Text(" 分").font(.body))
                    Text("目標の--%")
                        .font(.caption)
                        .foregroundStyle(AppColor.secondaryText)
                }
            }
            WeeklyMinutesChart(days: days)
        }
    }

    private var restDayCard: some View {
        CardContainer {
            HStack {
                Text("部位ごとの休息期間")
                    .font(.headline)
                Spacer()
                Image(systemName: "gearshape")
                    .foregroundStyle(AppColor.secondaryText)
            }
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 4),
                spacing: AppSpacing.medium
            ) {
                ForEach(MuscleGroup.allCases) { group in
                    CircularRestGauge(
                        muscleGroup: group,
                        status: viewModel.restStatus(for: group, sessions: sessions),
                        targetDays: viewModel.restTarget(for: group)
                    )
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(PersistenceController.makeContainer(inMemory: true))
}
