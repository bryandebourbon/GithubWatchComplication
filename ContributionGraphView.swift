import SwiftUI
import WidgetKit

struct ContributionGraphView: View {
  @Binding var contributions: [ContributionDay]
  private let blockSize: CGFloat = 8
  private let padding: CGFloat = 2
  private let numberOfRows: Int = 7
  private let maxWidth: CGFloat = 200

  private func colorForContributionCount(_ count: Int) -> Color {
    switch count {
    case 0: return Color.gray.opacity(0.4)
    case 1...3: return Color.green.opacity(0.6)
    case 4...6: return Color.green.opacity(0.9)
    default: return Color.green
    }
  }

  private var numberOfColumns: Int {
    let totalPadding = padding * (CGFloat(numberOfRows) + 1)
    let availableWidth = maxWidth - totalPadding
    return Int(availableWidth / (blockSize + padding))
  }

  private var contributionMapping: [String: Int] {
    Dictionary(
      contributions.map { ($0.date, $0.contributionCount) }, uniquingKeysWith: { first, _ in first }
    )
  }

  private var startOfCurrentWeek: Date {
    let calendar = Calendar.current
    let today = Date()
    return calendar.date(
      from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
  }

  private var startDate: Date {
    let calendar = Calendar.current
    let today = Date()
    let weekdayOffset = calendar.component(.weekday, from: today) - 1  // Offset for the current day of the week
    let totalDays = numberOfRows * (numberOfColumns - 1) + weekdayOffset
    return calendar.date(byAdding: .day, value: -totalDays, to: today)!
  }
  private func getDateForIndex(_ index: Int) -> String {
    let calendar = Calendar.current
    let startDate = self.startDate
    guard let date = calendar.date(byAdding: .day, value: index, to: startDate) else { return "" }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }

  private func daysInCurrentWeekPassed() -> Int {
    let calendar = Calendar.current
    let today = Date()
    let weekday = calendar.component(.weekday, from: today)
    // Adjusting according to your week start (Sunday = 1, Monday = 2, etc.)
    return weekday
  }

  var body: some View {
    VStack(alignment: .leading, spacing: padding) {
      ForEach(0..<numberOfRows, id: \.self) { rowIndex in
        HStack(spacing: padding) {
          ForEach(0..<numberOfColumns, id: \.self) { columnIndex in
            let index = rowIndex + columnIndex * numberOfRows
            let date = getDateForIndex(index)
            let contributionCount = contributionMapping[date] ?? 0

            if shouldDisplaySquare(at: columnIndex, rowIndex: rowIndex) {
              Rectangle()
                .fill(colorForContributionCount(contributionCount))
                .frame(width: blockSize, height: blockSize)
                .cornerRadius(2)
            }
          }
        }
      }
    }
    .padding(.all, padding)
    .frame(
      width: CGFloat(numberOfColumns) * (blockSize + padding) + padding,
      height: CGFloat(numberOfRows) * (blockSize + padding) + padding)
  }

  private func shouldDisplaySquare(at columnIndex: Int, rowIndex: Int) -> Bool {
    if columnIndex == numberOfColumns - 1 {
      // For the rightmost column, check if the rowIndex is within the days passed
      return rowIndex < daysInCurrentWeekPassed()
    }
    return dateIsInPast(getDateForIndex(rowIndex + columnIndex * numberOfRows))
  }

  private func dateIsInPast(_ dateString: String) -> Bool {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    guard let date = formatter.date(from: dateString) else { return false }
    return date <= Date()
  }

}

#if DEBUG
  struct ContributionGraphView_Previews: PreviewProvider {
    static var model = ContributionsModel()  // Make 'model' static
    static var contributions: [ContributionDay] = model.generateMockData()

    static var previews: some View {
        ContributionGraphView(contributions: .constant(contributions))
        .previewLayout(.fixed(width: 200, height: 110))
    }
  }
#endif
