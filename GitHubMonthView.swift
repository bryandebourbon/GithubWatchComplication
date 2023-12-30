import SwiftUI

struct GitHubMonthView: View {
  @Binding var contributions: [ContributionDay]


  var body: some View {
    VStack {
      SimpleContributionGraphView(
        originalContent: contributions.enumerated().map { index, contributionDay in
          AnyView(self.contributionView(for: contributionDay, index: index))
        },
        defaultView: AnyView(self.defaultDayView())
      )
    }
  }

  private func contributionView(for contributionDay: ContributionDay, index: Int) -> some View {
    let color = colorForContributionCount(contributionDay.contributionCount)
    return Rectangle()
      .fill(color)

  }

  private func colorForContributionCount(_ count: Int) -> Color {
    switch count {
    case 0:
      return Color.gray.opacity(0.3)
    case 1...3:
      return Color.green.opacity(0.4)
    case 4...6:
      return Color.green.opacity(0.6)
    default:
      return Color.green
    }
  }

  private func defaultDayView() -> some View {
    Rectangle()
      .fill(Color.gray.opacity(0.3))
  }
}

import SwiftUI

struct GitHubMonthView_Previews: PreviewProvider {
  static var model = ContributionsModel()  // 'model' should be static for previews
  static var contributions: [ContributionDay] = model.generateMockDataMonth()

  static var previews: some View {
    GitHubMonthView(contributions: .constant(contributions))
      .previewLayout(.fixed(width: 200, height: 110))
  }
}

// ... (rest of your GitHubMonthView struct)
