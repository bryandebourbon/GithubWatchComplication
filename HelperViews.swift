import SwiftUI

struct MonthLabelView: View {
  var rowIndex: Int
  var blockHeight: CGFloat
  var monthLabelWidth: CGFloat
  var monthName: String

  var body: some View {
    if rowIndex == 0 {
      Text(monthName)
        .font(.caption)
        .frame(width: monthLabelWidth, height: blockHeight)
    } else {
      Text("")  // Empty space for other rows
        .frame(width: monthLabelWidth, height: blockHeight)
    }
  }
}

struct BlockView: View {
  var rowIndex: Int
  var columnIndex: Int
  var numberOfColumns: Int
  var startingDayOfMonth: Int
  var daysInMonth: Int
  @Binding var caloricContributions: [(caloriesBurned: Double, caloriesConsumed: Double)]
  var blockWidth: CGFloat
  var blockHeight: CGFloat

  var body: some View {
    let index = rowIndex * numberOfColumns + columnIndex
    if index >= startingDayOfMonth && index < startingDayOfMonth + daysInMonth {
      let contentIndex = index - startingDayOfMonth
      return AnyView(
        createDataView(index: contentIndex)
          .frame(width: blockWidth, height: blockHeight)
          .cornerRadius(2)
      )
    } else {
      return AnyView(
        Color.black
          .frame(width: blockWidth, height: blockHeight)
          .cornerRadius(2)
      )
    }
  }

  private func createDataView(index: Int) -> DataView {
    let isToday = Calendar.current.component(.day, from: Date()) == index + 1
    let data = index < caloricContributions.count ? caloricContributions[index] : (0, 0)
    return DataView(
      data: data,
      isToday: isToday,
      isInFuture: index + 1 > caloricContributions.count,
      thresholdFunction: { burned, consumed in
        burned > consumed ? 1.0 : 0.5
      }
    )
  }
}
struct DayHeadersView: View {
  var daysOfWeek: [String]
  var blockWidth: CGFloat
  var blockHeight: CGFloat
  var monthLabelWidth: CGFloat
  var padding: CGFloat

  var body: some View {
    HStack(spacing: padding) {
      Text("").frame(width: monthLabelWidth)  // Placeholder for alignment
      ForEach(daysOfWeek, id: \.self) { day in
        Text(day).font(.caption).frame(width: blockWidth, height: blockHeight)
      }
    }
  }
}

struct MonthGridView: View {
  var numberOfRows: Int
  var numberOfColumns: Int
  var startingDayOfMonth: Int
  var daysInMonth: Int
  @Binding var caloricContributions: [(caloriesBurned: Double, caloriesConsumed: Double)]
  var blockWidth: CGFloat
  var blockHeight: CGFloat
  var monthLabelWidth: CGFloat
  var monthName: String
  var padding: CGFloat

  var body: some View {
    ForEach(0..<numberOfRows, id: \.self) { rowIndex in
      HStack(spacing: padding) {
        MonthLabelView(
          rowIndex: rowIndex, blockHeight: blockHeight, monthLabelWidth: monthLabelWidth,
          monthName: monthName)
        ForEach(0..<numberOfColumns, id: \.self) { columnIndex in
          BlockView(
            rowIndex: rowIndex, columnIndex: columnIndex, numberOfColumns: numberOfColumns,
            startingDayOfMonth: startingDayOfMonth, daysInMonth: daysInMonth,
            caloricContributions: $caloricContributions, blockWidth: blockWidth,
            blockHeight: blockHeight)
        }
      }
    }
  }
}
