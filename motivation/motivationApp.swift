
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
  @State private var sharedArray: [ContributionDay] = []

  func refreshSharedArray() {
    SharedUserDefaults.shared.addContributionDays {
      DispatchQueue.main.async {
        let array = SharedUserDefaults.shared.getSharedArray()
        self.sharedArray = array.filter { isCurrentMonth($0.date) }
        print(array)
      }
    }
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

  var body: some View {
    // Your existing VStack and other UI components
    VStack {
      Spacer()
      GitHubMonthView(contributions: $sharedArray).frame(width: 400, height: 200)
      Spacer()
      Button("Refresh ") {
        refreshSharedArray()
      }
      Button("Send") {
        WatchConnectivityManager.shared.sendContributionDays(contributionDays: sharedArray)
      }
      Spacer()
    }.onAppear {
      refreshSharedArray()
    }.onChange(of: sharedArray) {
      //      print("sharedArray updated: \(sharedArray)")
    }

  }
}

#Preview{
  ContentView()
}
