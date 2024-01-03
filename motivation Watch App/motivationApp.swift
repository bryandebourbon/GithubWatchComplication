import SwiftUI
import WatchConnectivity
import WidgetKit

@main
struct motivation_Watch_AppApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .onAppear {
          WatchSessionManager.shared.startSession()
        }
    }
  }
}

struct ContentView: View {
  @State private var sharedArray: [ContributionDay] = []
  @State private var eventDays: [EventCountDay] = []  // Add this line

  let didUpdateSharedArray = NotificationCenter.default.publisher(
    for: NSNotification.Name("UpdatedSharedArray"))

  var body: some View {
    VStack {
      GitHubMonthView(contributions: $sharedArray, eventDays: $eventDays)
      HStack {
        Button("Git") {
          updateSharedArray()
          refreshSharedArray()

        }
        Button("Cal") {
          EventKitFetcher.shared.requestCalendarAccess { granted in
            if granted {
              self.loadEventData()
            } else {
              print("Calendar access denied")
            }
          }
          SharedUserDefaults.shared.updateData {
            WidgetCenter.shared.reloadAllTimelines()
          }
        }
      }
    }
    .onAppear {
      updateSharedArray()
      refreshSharedArray()
    }
    .onReceive(didUpdateSharedArray) { _ in
      updateSharedArray()
    }
  }

  func loadEventData() {
    print("load executed")
    EventKitFetcher.shared.fetchEvents { events in
      DispatchQueue.main.async {
        print(events)
        self.eventDays = events
      }
    }
  }
  func updateSharedArray() {

    if let data = SharedUserDefaults.shared.userDefaults?.data(forKey: "sharedArray"),
      let contributionDays = try? JSONDecoder().decode([ContributionDay].self, from: data)
    {
      self.sharedArray = contributionDays
    }

    if let eventData = SharedUserDefaults.shared.userDefaults?.data(forKey: "eventDays"),
      let eventDays = try? JSONDecoder().decode([EventCountDay].self, from: eventData)
    {
      self.eventDays = eventDays
      print("Updated event days: \(eventDays)")
    }
  }

  func refreshSharedArray() {
    SharedUserDefaults.shared.addContributionDays {
      DispatchQueue.main.async {
        let array = SharedUserDefaults.shared.getContributionDays()  // Updated this line
        self.sharedArray = array.filter { isCurrentMonth($0.date) }
      }
    }

    SharedUserDefaults.shared.updateData {
      WidgetCenter.shared.reloadAllTimelines()
    }
  }
}

class WatchSessionManager: NSObject, WCSessionDelegate {
  static let shared = WatchSessionManager()

  func startSession() {
    if WCSession.isSupported() {
      let session = WCSession.default
      session.delegate = self
      session.activate()
    }
  }

  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any])
  {
    if let contributionDaysData = applicationContext["contributionDays"] as? Data {
      saveContributionDays(data: contributionDaysData)
    }

    if let eventDaysData = applicationContext["eventDays"] as? Data {
      saveEventDays(data: eventDaysData)
    }
  }

  private func saveEventDays(data: Data) {
    SharedUserDefaults.shared.userDefaults?.set(data, forKey: "eventDays")
    NotificationCenter.default.post(name: NSNotification.Name("UpdatedSharedArray"), object: nil)
  }

  private func saveContributionDays(data: Data) {
    SharedUserDefaults.shared.userDefaults?.set(data, forKey: "sharedArray")
    NotificationCenter.default.post(name: NSNotification.Name("UpdatedSharedArray"), object: nil)
  }

  // WCSessionDelegate methods
  func session(
    _ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    // Handle session activation completion
  }
}

#Preview{
  ContentView()
}
