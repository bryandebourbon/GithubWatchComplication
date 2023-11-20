import Foundation
import SwiftUI
import WatchConnectivity

@main
struct motivation_Watch_AppApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

struct ContentView: View {
  @State private var sharedArray: [ContributionDay] = []



  var body: some View {
    VStack {
      ContributionGraphView(contributions: sharedArray)

      Button("Fetch Github") {
        SharedUserDefaults.shared.addContributionDays()
        refreshSharedArray()
      }

    }.containerBackground(for: .widget) {
      Color.black
    }
    .onAppear {
      // Refresh the data when the view appears
      refreshSharedArray()
    }
  }

  private func refreshSharedArray() {
    sharedArray = SharedUserDefaults.shared.getSharedArray()
  }
}
