import Foundation
import WidgetKit

class SharedUserDefaults {
  static let shared = SharedUserDefaults()
  let userDefaults: UserDefaults?
  static let fetcher = GitHubDataFetcher()

  init() {
    userDefaults = UserDefaults(suiteName: "group.com.bryandebourbon.shared")
  }

  func getEnvironmentVariable(named name: String) -> String? {
    return ProcessInfo.processInfo.environment[name]
  }

  func addContributionDays(completion: @escaping () -> Void) {
    SharedUserDefaults.fetcher.fetchGitHubData(
      accessToken: "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"
    ) { result in
      switch result {
        case .success(let response):
          let newContributionDays = response.data.viewer.contributionsCollection
            .contributionCalendar
            .weeks
            .flatMap { $0.contributionDays }

          // Save the updated array
          if let encodedData = try? JSONEncoder().encode(newContributionDays) {
            self.userDefaults?.set(encodedData, forKey: "contributionDays")
            WidgetCenter.shared.reloadAllTimelines()
          }
          completion()
        case .failure(let error):
          print("Error fetching data: \(error)")
      }
    }
  }

  func getContributionDays() -> [ContributionDay] {
    guard let data = userDefaults?.data(forKey: "contributionDays"),
          let contributionDays = try? JSONDecoder().decode([ContributionDay].self, from: data) else {
      return []
    }
    return contributionDays
  }

  func saveEventDays(eventDays: [EventCountDay]) {
    if let encodedData = try? JSONEncoder().encode(eventDays) {
      userDefaults?.set(encodedData, forKey: "eventDays")
      WidgetCenter.shared.reloadAllTimelines()
    }
  }

  func getEventDays() -> [EventCountDay] {
    guard let data = userDefaults?.data(forKey: "eventDays"),
          let eventDays = try? JSONDecoder().decode([EventCountDay].self, from: data) else {
      return []
    }
    return eventDays
  }
}
