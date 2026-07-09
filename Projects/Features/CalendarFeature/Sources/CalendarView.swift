import SwiftUI
import SwiftData
import CoreKit
import DesignSystem
import WorkoutFeature

public struct CalendarView: View {
    @Query(sort: \WorkoutSession.date) private var sessions: [WorkoutSession]
    @State private var viewModel = CalendarViewModel()
    @State private var displayedMonth = Date()
    @State private var selectedDate: Date?

    private let weekdaySymbols = ["日", "月", "火", "水", "木", "金", "土"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    monthHeader
                    weekdayHeader
                    monthGrid
                    Divider()
                    dayDetail
                }
            }
            .navigationTitle("カレンダー")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { await viewModel.onAppear() }
    }

    private var monthHeader: some View {
        VStack(spacing: AppSpacing.medium) {
            HStack {
                Button {
                    displayedMonth = viewModel.previousMonth(from: displayedMonth)
                    selectedDate = nil
                } label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(viewModel.monthLabel(for: displayedMonth))
                    .font(.title3.bold())
                Spacer()
                Button {
                    displayedMonth = viewModel.nextMonth(from: displayedMonth)
                    selectedDate = nil
                } label: {
                    Image(systemName: "chevron.right")
                }
            }

            let summary = viewModel.monthSummary(for: displayedMonth, sessions: sessions)
            HStack {
                summaryColumn(label: "実施日", value: "\(summary.trainedDays)", unit: "days")
                Spacer()
                summaryColumn(label: "種目数", value: "\(summary.exerciseCount)", unit: "個")
                Spacer()
                summaryColumn(label: "実施時間", value: "\(summary.totalMinutes)", unit: "m")
            }
        }
        .padding(AppSpacing.medium)
        .background(AppColor.screenBackground)
    }

    private func summaryColumn(label: String, value: String, unit: String) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.caption).foregroundStyle(AppColor.secondaryText)
            (Text(value).font(.title3.bold()) + Text(" \(unit)").font(.caption))
        }
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { index, symbol in
                Text(symbol)
                    .font(.caption)
                    .foregroundStyle(index == 0 ? AppColor.danger : (index == 6 ? .blue : AppColor.secondaryText))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, AppSpacing.small)
    }

    private var monthGrid: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.medium) {
            ForEach(Array(viewModel.gridDays(for: displayedMonth).enumerated()), id: \.offset) { _, day in
                if let day {
                    dayCell(day)
                } else {
                    Color.clear.frame(height: 56)
                }
            }
        }
        .padding(.horizontal, AppSpacing.small)
        .padding(.vertical, AppSpacing.medium)
    }

    private func dayCell(_ day: Date) -> some View {
        let groups = viewModel.muscleGroups(on: day, in: sessions)
        let isSelected = selectedDate.map { Calendar.current.isDate(day, inSameDayAs: $0) } ?? false
        let isToday = Calendar.current.isDateInToday(day)
        return Button {
            selectedDate = day
        } label: {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: day))")
                    .font(.body)
                    .foregroundStyle(isSelected || isToday ? AppColor.brand : .primary)
                    .fontWeight(isSelected || isToday ? .bold : .regular)
                HStack(spacing: 2) {
                    ForEach(groups.prefix(4)) { group in
                        Circle().fill(group.color).frame(width: 5, height: 5)
                    }
                }
                .frame(height: 6)
            }
            .frame(height: 56)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private static let dayHeaderFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月 d日 (E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()

    @ViewBuilder
    private var dayDetail: some View {
        if let selectedDate {
            singleDayDetail(selectedDate)
        } else {
            monthSessionsList
        }
    }

    private func singleDayDetail(_ date: Date) -> some View {
        let daySessions = viewModel.sessions(on: date, in: sessions)

        return VStack(alignment: .leading, spacing: 0) {
            Text(Self.dayHeaderFormatter.string(from: date))
                .font(.subheadline)
                .foregroundStyle(AppColor.secondaryText)
                .padding(AppSpacing.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColor.screenBackground)

            if daySessions.isEmpty {
                NavigationLink {
                    RecordEntryView(date: date)
                } label: {
                    Text("記録を追加する")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.medium)
                        .background(AppColor.brand, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(AppSpacing.medium)
            } else {
                ForEach(daySessions) { session in
                    sessionRow(session)
                    Divider().padding(.leading, AppSpacing.medium)
                }
            }
        }
    }

    @ViewBuilder
    private var monthSessionsList: some View {
        let groups = viewModel.sessionsByDay(for: displayedMonth, sessions: sessions)
        if !groups.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(groups) { group in
                    Text(Self.dayHeaderFormatter.string(from: group.date))
                        .font(.subheadline)
                        .foregroundStyle(AppColor.secondaryText)
                        .padding(AppSpacing.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColor.screenBackground)

                    ForEach(group.sessions) { session in
                        sessionRow(session)
                        Divider().padding(.leading, AppSpacing.medium)
                    }
                }
            }
        }
    }

    private func sessionRow(_ session: WorkoutSession) -> some View {
        NavigationLink {
            SessionSummaryView(session: session)
        } label: {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                HStack {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .foregroundStyle(AppColor.brand)
                    Text("トレーニング記録")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(session.date.formatted(date: .omitted, time: .shortened))
                        .font(.footnote)
                        .foregroundStyle(AppColor.secondaryText)
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundStyle(AppColor.secondaryText)
                }
                ForEach(session.entries.sorted { $0.sortOrder < $1.sortOrder }) { entry in
                    HStack {
                        Circle().fill(entry.muscleGroup.color).frame(width: 6, height: 6)
                        Text(entry.exerciseName)
                            .foregroundStyle(.primary)
                        Spacer()
                        Text("\(Int(entry.totalVolume))kg")
                            .foregroundStyle(AppColor.secondaryText)
                    }
                    .font(.subheadline)
                }
            }
            .padding(AppSpacing.medium)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CalendarView()
        .modelContainer(PersistenceController.makeContainer(inMemory: true))
}
