import Foundation

class ContributionsModel: ObservableObject {
  @Published var contributions: [ContributionDay] = []

  init() {
    loadContributions()
  }

  func loadContributions() {
    let sharedDefaults = UserDefaults(suiteName: "group.com.bryandebourbon.shared")
    if let encodedData = sharedDefaults?.data(forKey: "githubContributions"),
      let contributionDays = try? JSONDecoder().decode([ContributionDay].self, from: encodedData)
    {
      DispatchQueue.main.async {
        self.contributions = contributionDays
      }
    }
  }

  private func storeContributionsInUserDefaults(_ contributionDays: [ContributionDay]) {
    if let encodedData = try? JSONEncoder().encode(contributionDays) {
      UserDefaults(suiteName: "group.com.bryandebourbon.shared")?.set(
        encodedData, forKey: "githubContributions")
    }
  }

  // Existing GitHubDataFetcher and other struct definitions...

  // Function to generate mock data
  func generateMockDataYear() -> [ContributionDay] {
    let calendar = Calendar.current
    let today = Date()
    var mockContributions = [ContributionDay]()

    // Generate mock data for the past 365 days
    for dayOffset in 0..<365 {
      guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      let dateString = formatter.string(from: date)
      let contributionCount = Int.random(in: 0...10)  // Random contribution count
      mockContributions.append(
        ContributionDay(date: dateString, contributionCount: contributionCount))
    }

    return mockContributions

  }
  func generateMockDataMonth() -> [ContributionDay] {
    let calendar = Calendar.current
    let today = Date()
    var mockContributions = [ContributionDay]()

    // Generate mock data for the past 365 days
    for dayOffset in 0..<30 {
      guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      let dateString = formatter.string(from: date)
      let contributionCount = Int.random(in: 0...10)  // Random contribution count
      mockContributions.append(
        ContributionDay(date: dateString, contributionCount: contributionCount))
    }

    return mockContributions

  }
}


func generateCurrentMonthMockData() -> [ContributionDay] {
  let calendar = Calendar.current
  let today = Date()
  _ = calendar.component(.month, from: today)
  _ = calendar.component(.year, from: today)
  let range = calendar.range(of: .day, in: .month, for: today)!

  var mockContributions = [ContributionDay]()

  for dayOffset in 1...range.count  {
    guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let dateString = formatter.string(from: date)
    let contributionCount = Int.random(in: 0...10)  // Random contribution count
    mockContributions.append(
      ContributionDay(date: dateString, contributionCount: contributionCount))
  }

  return mockContributions
}
