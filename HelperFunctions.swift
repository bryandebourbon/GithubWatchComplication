import Foundation

struct GridCalculator {
  private let calendar = Calendar.current
  let currentDate: Date
  let numberOfColumns = 7
  let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

  var numberOfRows: Int {
    let totalDays = daysInMonth + startingDayOfMonth
    return (totalDays + 6) / 7 + 1
  }

  var daysInMonth: Int {
    calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 30
  }

  var startingDayOfMonth: Int {
    let components = calendar.dateComponents([.year, .month], from: currentDate)
    let firstDayOfMonth = calendar.date(from: components)!
    return calendar.component(.weekday, from: firstDayOfMonth) - 1
  }

  var monthName: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM"
    return dateFormatter.string(from: currentDate)
  }

  func calculateBlockWidth(containerWidth: CGFloat, monthLabelWidth: CGFloat, padding: CGFloat)
    -> CGFloat
  {
    (containerWidth - monthLabelWidth - padding * (CGFloat(numberOfColumns) + 2))
      / CGFloat(numberOfColumns)
  }

  func calculateBlockHeight(containerHeight: CGFloat, padding: CGFloat) -> CGFloat {
    (containerHeight - padding * (CGFloat(numberOfRows) + 1)) / CGFloat(numberOfRows)
  }
}
