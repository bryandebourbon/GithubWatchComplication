import HealthKit
import SwiftUI

struct InfiniteGraphView: View {
  @Binding var caloricContributions: [(caloriesBurned: Double, caloriesConsumed: Double)]
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

      VStack(alignment: .leading, spacing: padding) {
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
          caloricContributions: $caloricContributions,
          blockWidth: blockWidth,
          blockHeight: blockHeight,
          monthLabelWidth: monthLabelWidth,
          monthName: gridCalculator.monthName,
          padding: padding
        )
      }
      .padding(.all, padding)
    }
    .onAppear {
      fetchHealthData()
    }
  }

  private func fetchHealthData() {
    healthKitFetcher.update()
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      self.caloricContributions = healthKitFetcher.dailyData
    }
  }
}

// Define GridCalculator, DayHeadersView, MonthGridView, MonthLabelView, BlockView, DataView...

// EnhancedContributionGraphView Preview
struct EnhancedContributionGraphView_Previews: PreviewProvider {
  static var previews: some View {
      InfiniteGraphView(caloricContributions: .constant([]))
      .frame(width: 250, height: 100)
      .previewLayout(.sizeThatFits)
  }
}
