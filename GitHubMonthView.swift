import SwiftUI
import EventKit

struct GitHubMonthView: View {
  @Binding var contributions: [ContributionDay]
  @Binding var eventDays: [EventCountDay]{
    didSet
    {
    print(eventDays)
    }
  }


  var body: some View {
    VStack {
      SimpleContributionGraphView(
        originalContent: self.fullMonthContent(),
        defaultView: AnyView(self.defaultDayView())
      )
    }
  }
  private func fullMonthContent() -> [AnyView] {
    let calendar = Calendar.current
    let startOfMonth = calendar.startOfMonth(for: Date())
    let range = calendar.range(of: .day, in: .month, for: Date())!

    return (0..<range.count).map { day in
      let currentDate = calendar.date(byAdding: .day, value: day, to: startOfMonth)!
      let dateString = dateFormatter.string(from: currentDate)

      if let contribution = contributions.first(where: { $0.date == dateString }) {
        return AnyView(self.contributionView(for: contribution, index: 0))
      } else if let _ = eventDays.first(where: { $0.date == dateString }) {
        return AnyView(
          ZStack{
          Rectangle()
              .fill(Color.gray)

          Circle().fill(Color.red)
        }
        ) // Red dot for event days
      } else {
        return AnyView(self.defaultDayView()) // Default view for no contributions/events
      }
    }
  }
  private var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }

  private func contributionView(for contributionDay: ContributionDay, index: Int) -> some View {
    let color = colorForContributionCount(contributionDay.contributionCount)
    let hasEvent = eventDays.contains { eventDay in
      eventDay.date == contributionDay.date
    }

    print("Date: \(contributionDay.date), Has Event: \(hasEvent)")

    return ZStack {
      // Gray rectangle background
      Rectangle()
        .fill(color)

      // Circle on top of the rectangle
      if hasEvent {
        Circle()
          .fill(Color.red)
      }
    }
  }


  private func colorForContributionCount(_ count: Int) -> Color {
    switch count {
      case 0:
        return Color.gray
      case 1...3:
        return Color.green.opacity(0.7)
      case 4...6:
        return Color.green.opacity(0.9)
      default:
        return Color.green
    }
  }

  private func defaultDayView() -> some View {
    Rectangle()
      .fill(Color.gray)
  }
}


struct GitHubMonthView_Previews: PreviewProvider {
  static var model = ContributionsModel()
  static var contributions: [ContributionDay] = model.generateMockDataMonth()
  static var mockEventDays: [EventCountDay] = EventKitFetcher.generateWeeklyMockEventData()

  static var previews: some View {
    GitHubMonthView(contributions: .constant(contributions), eventDays: .constant(mockEventDays))
      .previewLayout(.fixed(width: 200, height: 110))
  }
}


extension Calendar {
  func startOfMonth(for date: Date) -> Date {
    let components = dateComponents([.year, .month], from: date)
    return self.date(from: components)!
  }
}




