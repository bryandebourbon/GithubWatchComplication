import EventKit

class EventKitFetcher {
  private let eventStore = EKEventStore()

  func requestAccess(completion: @escaping (Bool, Error?) -> Void) {
    eventStore.requestFullAccessToEvents { granted, error in
      completion(granted, error)
    }
  }

  func fetchEvents(from startDate: Date, to endDate: Date, completion: @escaping ([ContributionDay]) -> Void) {
    let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
    let events = eventStore.events(matching: predicate)

    var contributions: [String: Int] = [:]
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    for event in events {
      let dateString = dateFormatter.string(from: event.startDate)
      contributions[dateString, default: 0] += 1
    }

    let contributionDays = contributions.map { ContributionDay(date: $0.key, contributionCount: $0.value) }
    completion(contributionDays)
  }
}
