import EventKit
import SwiftUI

struct GitHubMonthView: View {
  @Binding var contributions: [ContributionDay]
  @Binding var eventDays: [EventCountDay]
  let todayEllipse: some View = Ellipse().fill(.black).frame(width: 20, height: 7).opacity(0.5)
  let todayEllipseRed: some View = Ellipse().fill(.black).frame(width: 20, height: 7)

  var body: some View {
    VStack {
      Text("\(currentMonthName.uppercased())")
        .font(.system(size: 12).bold().monospaced())
      SimpleContributionGraphView(
        originalContent: self.fullMonthContent(),
        defaultView: AnyView(Rectangle())
      )
    }
  }

  private var currentMonthName: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE MMMM d yyyy"  // Format for full month name
    return formatter.string(from: Date())
  }

  private func fullMonthContent() -> [AnyView] {
    let calendar = Calendar.current
    let startOfMonth = calendar.startOfMonth(for: Date())
    let range = calendar.range(of: .day, in: .month, for: Date())!
    return (0..<range.count).map { day in
      let currentDate = calendar.date(byAdding: .day, value: day, to: startOfMonth)!
      let dateString = dateFormatter.string(from: currentDate)
      let dayOfMonth = calendar.component(.day, from: currentDate)
      let isToday = calendar.isDateInToday(currentDate)

      if let contribution = contributions.first(where: { $0.date == dateString }) {
        return AnyView(
          self.contributionView(for: contribution, index: dayOfMonth, isToday: isToday))

      } else if let eventDay = eventDays.first(where: { $0.date == dateString }) {
        let hasContributions = contributions.contains { $0.date == dateString }
        return AnyView(
          self.eventDayView(
            dayOfMonth: dayOfMonth, isToday: isToday, hasContributions: hasContributions))
      } else {
        return AnyView(self.defaultDayView(dayOfMonth: dayOfMonth, isToday: isToday))
      }

    }
  }

  private func eventDayView(dayOfMonth: Int, isToday: Bool, hasContributions: Bool) -> some View {
    ZStack {
      Rectangle().fill(Color.red.opacity(0.5))
      if isToday {
        Ellipse().fill(hasContributions ? Color.black : Color.red).frame(width: 10, height: 8)
          .opacity(0.5)
      }
      Text("\(dayOfMonth)")
        .font(.system(size: 9)).bold()
        .foregroundColor(.white)
    }
  }

  private func contributionView(for contributionDay: ContributionDay, index: Int, isToday: Bool)
    -> some View
  {
    let color = colorForContributionCount(contributionDay.contributionCount)

    return ZStack {
      Rectangle().fill(color)
      if isToday {

        if contributionDay.contributionCount == 0 {
          Rectangle().fill(.gray).opacity(0.6)
          todayEllipseRed

        } else {
          todayEllipse

        }
      }
      Text("\(index)").bold()
        .font(.system(size: (isToday ? 10 : 9)))
        .foregroundColor(.white)
    }

  }

  private var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }
  private func colorForContributionCount(_ count: Int) -> Color {
    switch count {
    case 0:
      return Color.gray.opacity(0.3)
    case 1:
      return Color.green.opacity(0.6)
    case 2:
      return Color.green.opacity(0.7)
    default:
      return Color.green.opacity(0.8)
    }
  }

  private func defaultDayView(dayOfMonth: Int, isToday: Bool) -> some View {
    print(dayOfMonth, isToday)
    return ZStack {
      Rectangle().fill(Color.gray.opacity(0.5))
      if isToday {
        todayEllipseRed
      }

      Text("\(dayOfMonth)").bold()
        .font(.system(size: 9))
        .foregroundColor(.white)

    }
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
