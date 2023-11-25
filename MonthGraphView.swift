import HealthKit
import SwiftUI

struct MonthGraphView: View {
  var monthData: MonthData
  var monthName: String  // Accept monthName as a parameter

  var healthKitFetcher = HealthKitFetcher()

  private let gridCalculator = GridCalculator(currentDate: Date())
  private let padding: CGFloat = 2
  private let monthLabelWidth: CGFloat = 40

  var body: some View {
    GeometryReader { geometry in
      let blockWidth = gridCalculator.calculateBlockWidth(
        containerWidth: geometry.size.width, monthLabelWidth: monthLabelWidth, padding: padding)
      let blockHeight = gridCalculator.calculateBlockHeight(
        containerHeight: geometry.size.height, padding: padding)

      VStack(
        alignment: .leading,
        spacing: padding
      ) {
        DayHeadersView(
          daysOfWeek: gridCalculator.daysOfWeek,
          blockWidth: blockWidth,
          blockHeight: blockHeight,
          monthLabelWidth: monthLabelWidth,
          padding: padding
        )
        MonthGridView(
          numberOfRows: gridCalculator.numberOfRows,
          numberOfColumns: gridCalculator.numberOfColumns,
          startingDayOfMonth: gridCalculator.startingDayOfMonth,
          daysInMonth: gridCalculator.daysInMonth,
          caloricContributions: .constant(
            monthData.dailyData.map { ($0.caloriesBurned, $0.caloriesConsumed) }),
          blockWidth: blockWidth,
          blockHeight: blockHeight,
          monthLabelWidth: monthLabelWidth,
          monthName: monthName,  // Use the passed monthName parameter here
          padding: padding
        )
      }
      .padding(.all, padding)
    }
  }
}
struct MonthGraphView_Previews: PreviewProvider {
  static var previews: some View {
    MonthGraphView(
      monthData: MonthData(
        month: Date(),
        dailyData: [
          DayData(day: Date(), caloriesBurned: 300, caloriesConsumed: 2500)
          // Add more DayData as needed
        ]), monthName: "Jan"
        // Add more MonthData as needed
    )
  }
}
