import SwiftUI
import WidgetKit

struct SimpleContributionGraphView<Content>: View where Content: View {
  let content: [Content]
  private let padding: CGFloat = 2
  private let numberOfRows: Int = 6
  private let numberOfColumns: Int = 7

  var body: some View {
    GeometryReader { geometry in
      let totalWidth = geometry.size.width
      let totalHeight = geometry.size.height
      let blockWidth =
        (totalWidth - padding * (CGFloat(numberOfColumns) + 1)) / CGFloat(numberOfColumns)
      let blockHeight =
        (totalHeight - padding * (CGFloat(numberOfRows) + 1)) / CGFloat(numberOfRows)

      VStack(alignment: .leading, spacing: padding) {
        ForEach(0..<numberOfRows, id: \.self) { rowIndex in
          HStack(spacing: padding) {
            ForEach(0..<numberOfColumns, id: \.self) { columnIndex in
              let index = rowIndex * numberOfColumns + columnIndex
              content[index]
                .frame(width: blockWidth, height: blockHeight)
                .cornerRadius(2)
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
        SimpleContributionGraphView(content: Array(repeating: Color.red, count: 28))
            .frame(width: 200, height: 50)
            .previewLayout(.sizeThatFits)
    }
}
