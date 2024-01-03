import EventKit


struct EventCountDay: Codable, Equatable {
  let date: String
  let eventCount: Int
}
func isCurrentMonth(_ dateString: String) -> Bool {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd"
  if let date = dateFormatter.date(from: dateString) {
    let calendar = Calendar.current
    let currentMonth = calendar.component(.month, from: Date())
    let month = calendar.component(.month, from: date)
    return month == currentMonth
  }
  return false
}

class EventKitFetcher {
  static let shared = EventKitFetcher()
  private let store = EKEventStore()

  private init() {}

  func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
    switch EKEventStore.authorizationStatus(for: .event) {
      case .notDetermined:
        store.requestFullAccessToEvents { granted, error in
          DispatchQueue.main.async {
            completion(granted)
          }
        }
      case .restricted, .denied, .authorized:
        completion(EKEventStore.authorizationStatus(for: .event) == .fullAccess)
      default:
        completion(false)
    }
  }

  func fetchEvents(completion: @escaping ([EventCountDay]) -> Void) {
    let calendar = Calendar.current

    // Get the start date (beginning of the current month)
    let components = calendar.dateComponents([.year, .month], from: Date())
    guard let startDate = calendar.date(from: components) else {
      completion([])
      return
    }

    // Get the end date (end of the current month)
    var endComponents = DateComponents()
    endComponents.month = 1
    endComponents.day = -1
    guard let endDate = calendar.date(byAdding: endComponents, to: startDate) else {
      completion([])
      return
    }

    // Create a predicate to fetch events within the date range
    let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)

    // Fetch events
    let events = store.events(matching: predicate)

    // Map and process events into your EventCountDay structure
    let eventDays = events.map { event in
      EventCountDay(date: dateFormatter.string(from: event.startDate), eventCount: 1) // Assuming 1 event per day for simplicity
    }

    // Call the completion handler with the processed events
    completion(eventDays)
  }


  private var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }


  static func generateMockEventData() -> [EventCountDay] {
    var mockEvents: [EventCountDay] = []
    let calendar = Calendar.current
    let endDate = Date()
    var dateComponents = DateComponents()
    dateComponents.day = -40
    let startDate = calendar.date(byAdding: dateComponents, to: endDate)!

    // Generate mock events for the last 40 days
    for day in 0..<40 {
      let mockDate = calendar.date(byAdding: .day, value: day, to: startDate)!
      let dateString = dateFormatter.string(from: mockDate)
      let mockEventCount = Int.random(in: 0...5) // Random event count
      mockEvents.append(EventCountDay(date: dateString, eventCount: mockEventCount))
    }

    return mockEvents
  }
  static func generateWeeklyMockEventData() -> [EventCountDay] {
    var mockEvents: [EventCountDay] = []
    let calendar = Calendar.current
    let endDate = Date()
    var dateComponents = DateComponents()
    dateComponents.day = -40

    let startDate = calendar.date(byAdding: dateComponents, to: endDate)!

    for day in stride(from: 0, to: 40, by: 7) {  // Once a week
      let mockDate = calendar.date(byAdding: .day, value: day, to: startDate)!
      let dateString = dateFormatter.string(from: mockDate)
      mockEvents.append(EventCountDay(date: dateString, eventCount: 1))  // 1 event per week
    }

    return mockEvents
  }

  private static var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }



}
