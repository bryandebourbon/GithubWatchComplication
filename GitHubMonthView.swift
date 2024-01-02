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
      Text("\(currentMonthName.uppercased())")
        .font(.system(size: 12).bold().monospaced()) // Apply font size to the Text view

      SimpleContributionGraphView(
        originalContent: self.fullMonthContent(),
        defaultView: AnyView(Rectangle())
      )
    }
  }
  private var currentMonthName: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE MMMM d yyyy" // Format for full month name
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
        return AnyView(self.contributionView(for: contribution, index: dayOfMonth, isToday: isToday))
      } else if let _ = eventDays.first(where: { $0.date == dateString }) {
        return AnyView(self.eventDayView(dayOfMonth: dayOfMonth, isToday: isToday))
      } else {
        return AnyView(self.defaultDayView(dayOfMonth: dayOfMonth, isToday: isToday))
      }
    }
  }

  private func eventDayView(dayOfMonth: Int, isToday:Bool) -> some View {
    ZStack {

      Rectangle().fill(Color.gray.opacity(0.3))
      Circle().fill(Color.blue)

      Rectangle().fill(Color.gray.opacity(0.3))
      Text("\(dayOfMonth)")
        .font(.system(size: 9)).bold()
        .foregroundColor(isToday ? Color(red: 1, green: 0, blue: 0): .black )
    }
  }


  private func contributionView(for contributionDay: ContributionDay, index: Int, isToday:Bool) -> some View {
    let color = colorForContributionCount(contributionDay.contributionCount)
    let hasEvent = eventDays.contains { eventDay in
      eventDay.date == contributionDay.date
    }

    return ZStack {

      Rectangle().fill(color)
      Rectangle().fill(Color.gray.opacity(0.3))
      if hasEvent && contributionDay.contributionCount == 0 {
        Circle().fill(Color.blue).frame(width: 7, height: 7)
        Text("\(index)").bold()
          .font(.system(size: 9))
          .foregroundColor(isToday ? Color(red: 1, green: 0, blue: 0) : .black )


      } else {

        Text("\(index)").bold()
          .font(.system(size: 9))
          .foregroundColor(isToday ? Color(red: 1, green: 0, blue: 0) : .white )

      }
    }
  }
  private func defaultDayView(dayOfMonth: Int) -> some View {
    ZStack {
      Rectangle().fill(Color.gray.opacity(0.3))
      
      Text("\(dayOfMonth)").bold()
        .font(.system(size: 9))
        .foregroundColor(.white) // Displaying the day of the month
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
        return Color.green.opacity(0.4)
      case 2:
        return Color.green.opacity(0.5)
      case 3:
        return Color.green.opacity(0.6)
      default:
        return  Color.green.opacity(0.7)
    }
  }

  private func defaultDayView(dayOfMonth: Int, isToday: Bool) -> some View {
    ZStack {
      Rectangle().fill(Color.gray.opacity(0.3))
      Text("\(dayOfMonth)").bold()
        .font(.system(size: 9))
        .foregroundColor(isToday ?  Color(red: 1, green: 0, blue: 0) : .white )




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




