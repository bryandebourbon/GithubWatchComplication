import SwiftUI
import WatchConnectivity

@main
struct motivationApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

struct ContentView: View {
  @State var sharedArray: [ContributionDay] = []
  @State var eventDays: [EventCountDay] = []

  func refreshSharedArray() {
    SharedUserDefaults.shared.addContributionDays {
      DispatchQueue.main.async {
        let array = SharedUserDefaults.shared.getContributionDays()  // Updated this line
        self.sharedArray = array.filter { isCurrentMonth($0.date) }
      }
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

  func sendEventDays(eventDays: [EventCountDay]) {
    do {
      let data = try JSONEncoder().encode(eventDays)
      try WCSession.default.updateApplicationContext(["eventDays": data])
    } catch {
      print("Error sending event days: \(error)")
    }
  }




  var body: some View {
    // Your existing VStack and other UI components
    VStack {
      Spacer()
      GitHubMonthView(
        contributions: $sharedArray, eventDays: $eventDays
      )
      .frame(width: 400, height: 200)
      Spacer()
      Button("Refresh ") {
        refreshSharedArray()
      }
      Spacer()
      Button("Load Calendar") {
        EventKitFetcher.shared.requestCalendarAccess { granted in
          if granted {
            self.loadEventData()
          } else {
            print("Calendar access denied")
          }
        }
      }



      Spacer()
      Button("Send") {
        WatchConnectivityManager.shared.sendContributionDays(contributionDays: sharedArray)
        WatchConnectivityManager.shared.sendEventDays(eventDays: eventDays)
      }

      Spacer()
    }.onAppear {
      refreshSharedArray()
      loadEventData()
    }.onChange(of: sharedArray) {
      //      print("sharedArray updated: \(sharedArray)")
    }

  }
}

#Preview{
  ContentView()
}
