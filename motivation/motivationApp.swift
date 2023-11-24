// iOS Part: motivationApp.swift
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
        self.sharedArray = array
        print(array)
      }
    }
  }

  var body: some View {
    VStack {

      Spacer()
      ContributionGraphView(contributions: $sharedArray)
      Spacer()
      CaloriesGraphView()
        .frame(width: 300, height: 60)

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

class WatchConnectivityManager: NSObject, WCSessionDelegate {
  static let shared = WatchConnectivityManager()

  override init() {
    super.init()
    if WCSession.isSupported() {
      let session = WCSession.default
      session.delegate = self
      session.activate()
    }
  }

  func sendContributionDays(contributionDays: [ContributionDay]) {
    if WCSession.isSupported() {
      let session = WCSession.default

      if session.isPaired && session.isWatchAppInstalled {
        do {
          let data = try JSONEncoder().encode(contributionDays)
          try session.updateApplicationContext(["contributionDays": data])
          print("****Contribution days sent: \(data)")
        } catch {
          print("*****Error sending contribution days: \(error)")
        }
      } else {
        print("*****Watch is not paired or the Watch app is not installed")
      }
    }
  }

  // WCSessionDelegate methods
  func session(
    _ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {}

  func sessionDidBecomeInactive(_ session: WCSession) {}

  func sessionDidDeactivate(_ session: WCSession) {}
}

#Preview{
  ContentView()
}
