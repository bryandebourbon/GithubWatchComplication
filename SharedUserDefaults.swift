import Foundation
import WidgetKit

class SharedUserDefaults {
  static let shared = SharedUserDefaults()
  let userDefaults: UserDefaults?
  static let fetcher = GitHubDataFetcher()

  init() {
    userDefaults = UserDefaults(suiteName: "group.com.bryandebourbon.shared")
  }

  func addContributionDays(completion: @escaping () -> Void) {
    SharedUserDefaults.fetcher.fetchGitHubData(
      accessToken: ""
    ) { result in
      switch result {
      case .success(let response):
        let newContributionDays = response.data.viewer.contributionsCollection
          .contributionCalendar
          .weeks
          .flatMap { $0.contributionDays }

        // Save the updated array
        if let encodedData = try? JSONEncoder().encode(newContributionDays) {
          self.userDefaults?.set(encodedData, forKey: "sharedArray")
          WidgetCenter.shared.reloadAllTimelines()
        }
        completion()
      case .failure(let error):
        print("Error fetching data: \(error)")
      }
    }
  }

  func getSharedArray() -> [ContributionDay] {
    print("in get Array")
    
    guard let data = userDefaults?.data(forKey: "sharedArray"),
      let contributionDays = try? JSONDecoder().decode([ContributionDay].self, from: data)
    else {
      return []
    }
    return contributionDays
  }
}
