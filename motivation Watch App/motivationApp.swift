// WatchOS Part: motivation_Watch_AppApp.swift
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

  var body: some View {
    VStack {
      ContributionGraphView(contributions: $sharedArray)
    }
    .onAppear {
      refreshSharedArray()
      NotificationCenter.default.addObserver(
        forName: NSNotification.Name("UpdatedSharedArray"), object: nil, queue: nil
      ) { _ in
        refreshSharedArray()
      }
    }
  }

  func refreshSharedArray() {
    self.sharedArray = SharedUserDefaults.shared.getSharedArray()
    WidgetCenter.shared.reloadAllTimelines()
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

  override init() {
    super.init()
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
  }

  private func saveContributionDays(data: Data) {
    SharedUserDefaults.shared.userDefaults?.set(data, forKey: "sharedArray")
    NotificationCenter.default.post(name: NSNotification.Name("UpdatedSharedArray"), object: nil)
  }

  // WCSessionDelegate methods
  func session(
    _ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {}

}
