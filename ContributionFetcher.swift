import Foundation

class GitHubDataFetcher {
  private let session: URLSession

  init() {
    self.session = URLSession.shared
  }

  func fetchGitHubData(
    accessToken: String, completion: @escaping (Result<GitHubQueryResponse, Error>) -> Void
  ) {
    let from = Calendar.current.date(byAdding: .weekOfYear, value: -18, to: Date())!
    let to = Date()
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]

    let fromDate = formatter.string(from: from)
    let toDate = formatter.string(from: to)

    let url = URL(string: "https://api.github.com/graphql")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let query = """
      query UserContributions {
          viewer {
              contributionsCollection(from: "\(fromDate)", to: "\(toDate)") {
                  contributionCalendar {
                      totalContributions
                      weeks {
                          contributionDays {
                              date
                              contributionCount
                          }
                      }
                  }
              }
          }
      }
      """

    let queryDict = ["query": query]
    if let httpBody = try? JSONSerialization.data(withJSONObject: queryDict) {
      request.httpBody = httpBody
    } else {
      // Handle error here
      print("ERROR")
    }

    let task = session.dataTask(with: request) { data, response, error in
      if let error = error {
        completion(.failure(error))
        return
      }

      guard let data = data else {
        completion(
          .failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])))
        return
      }

      // Print the raw JSON response
      if let rawJSONString = String(data: data, encoding: .utf8) {
        print("Raw JSON string: \(rawJSONString)")
      }

      do {
        let decodedResponse = try JSONDecoder().decode(GitHubQueryResponse.self, from: data)
        completion(.success(decodedResponse))
      } catch {
        // Print the decoding error
        print("Decoding error: \(error)")
        completion(.failure(error))
      }
    }

    task.resume()
  }

  private func iso8601String(from date: Date) -> String {
    let formatter = ISO8601DateFormatter()
    return formatter.string(from: date)
  }
}

struct GitHubQueryResponse: Codable {
  let data: ViewerData
}

struct ViewerData: Codable {
  let viewer: Viewer
}

struct Viewer: Codable {
  let contributionsCollection: ContributionsCollection
}

struct ContributionsCollection: Codable {
  let contributionCalendar: ContributionCalendar
}

struct ContributionCalendar: Codable {
  let totalContributions: Int
  let weeks: [Week]
}

struct Week: Codable {
  let contributionDays: [ContributionDay]
}

struct ContributionDay: Codable, Equatable {
    let date: String
    let contributionCount: Int
}
