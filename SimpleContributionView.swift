import SwiftUI

struct SimpleContributionGraphView<Content>: View where Content: View {
  let originalContent: [Content]
  let defaultView: Content
  private let calendar = Calendar.current
  private let currentDate = Date()  // You can replace this with the date of the month you want to display

  private let padding: CGFloat = 2
  private var numberOfRows: Int {
    let daysInMonth = self.daysInMonth
    let startingDayOfMonth = self.startingDayOfMonth
    let totalDays = daysInMonth + startingDayOfMonth
    return (totalDays + 6) / 7  // Calculate the number of rows dynamically
  }
  private var numberOfColumns: Int { return 7 }  // Always 7 columns for days of the week
  private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

  private var daysInMonth: Int {
    let range = calendar.range(of: .day, in: .month, for: currentDate)!
    return range.count
  }

  private var startingDayOfMonth: Int {
    let components = calendar.dateComponents([.year, .month], from: currentDate)
    let firstDayOfMonth = calendar.date(from: components)!
    return calendar.component(.weekday, from: firstDayOfMonth) - 1  // Adjust for 0-based index
  }

  private var totalBlocks: Int {
    return numberOfRows * numberOfColumns
  }

  var body: some View {
    GeometryReader { geometry in
      let totalWidth = geometry.size.width
      let totalHeight = geometry.size.height
      let blockWidth =
        (totalWidth - padding * (CGFloat(numberOfColumns) + 1)) / CGFloat(numberOfColumns)
      let blockHeight =
        (totalHeight - padding * (CGFloat(numberOfRows) + 1)) / CGFloat(numberOfRows)

      VStack(alignment: .leading, spacing: padding) {
        HStack(alignment: .center) {
//          Text("5pm FRXMAS").font(.system(size: 10))
//                    ForEach(daysOfWeek, id: \.self) { day in
//                      Text(day)
//                        .font(.caption)
//                        .frame(width: blockWidth, height: blockHeight)
        }

        ForEach(0..<numberOfRows, id: \.self) { rowIndex in
          HStack(spacing: padding) {
            ForEach(0..<numberOfColumns, id: \.self) { columnIndex in
              let index = rowIndex * numberOfColumns + columnIndex
              if index >= startingDayOfMonth && index < startingDayOfMonth + daysInMonth {
                let contentIndex = index - startingDayOfMonth
                (contentIndex < originalContent.count ? originalContent[contentIndex] : defaultView)
                  .frame(width: blockWidth, height: blockHeight)
                  .cornerRadius(2)
              } else {
                Color.black
                  .frame(width: blockWidth, height: blockHeight)
                  .cornerRadius(2)
              }
            }
          }
        }
      }
      .padding(.all, padding)
    }
  }
}

struct SimpleContributionGraphView_Previews: PreviewProvider {
  static var previews: some View {
    SimpleContributionGraphView(
      originalContent: Array(repeating: Color.red, count: 20), defaultView: Color.gray
    )
    .frame(width: 200, height: 110)
    .previewLayout(.sizeThatFits)
  }
}
