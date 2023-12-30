import WatchConnectivity

class WatchConnectivityManager: NSObject, WCSessionDelegate {
  static let shared = WatchConnectivityManager()

  private override init() {
    super.init()
    if WCSession.isSupported() {
      let session = WCSession.default
      session.delegate = self
      session.activate()
    }
  }

  func sendContributionDays(contributionDays: [ContributionDay]) {
    let session = WCSession.default

    guard session.isReachable else {
      print("Watch is not reachable")
      return
    }

    if session.activationState != .activated {
      print("WCSession is not activated")
      return
    }

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

  // WCSessionDelegate methods
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    // Handle session activation completion
    if activationState != .activated {
      print("WCSession not activated: \(String(describing: error))")
    }
  }

  func sessionDidBecomeInactive(_ session: WCSession) {
    // Handle session becoming inactive
  }

  func sessionDidDeactivate(_ session: WCSession) {
    // Handle session deactivation
    WCSession.default.activate() // Reactivate the session if needed
  }
}
