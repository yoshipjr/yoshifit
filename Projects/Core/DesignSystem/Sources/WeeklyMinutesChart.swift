import SwiftUI
import Charts
import CoreKit

public struct WeeklyMinutesChart: View {
    private let days: [WeeklyDayMinutes]

    public init(days: [WeeklyDayMinutes]) {
        self.days = days
    }

    private let weekdaySymbols = ["日", "月", "火", "水", "木", "金", "土"]

    public var body: some View {
        Chart(Array(days.enumerated()), id: \.offset) { index, day in
            BarMark(
                x: .value("曜日", weekdaySymbols[index]),
                y: .value("分", day.minutes)
            )
            .foregroundStyle(AppColor.brand.gradient)
            .cornerRadius(3)
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let label = value.as(String.self) {
                        Text(label)
                    }
                }
            }
        }
        .chartYAxis(.hidden)
        .frame(height: 140)
    }
}

#Preview {
    WeeklyMinutesChart(days: [
        .init(date: Date(), minutes: 0),
        .init(date: Date(), minutes: 39),
        .init(date: Date(), minutes: 0),
        .init(date: Date(), minutes: 0),
        .init(date: Date(), minutes: 0),
        .init(date: Date(), minutes: 0),
        .init(date: Date(), minutes: 0),
    ])
    .padding()
}
