import HealthKit
import SwiftUI

struct CaloriesGraphView: View {
  @Binding var caloricContributions: [(caloriesBurned: Double, caloriesConsumed: Double)]
  var healthKitFetcher = HealthKitFetcher()
  // Default initializer
  init(caloricContributions: Binding<[(caloriesBurned: Double, caloriesConsumed: Double)]>) {
    self._caloricContributions = caloricContributions
  }

  // Initializer with sample data
  init() {
    let sampleData = (0..<28).map { _ in
      (
        caloriesBurned: Double.random(in: 1000...9000),
        caloriesConsumed: Double.random(in: 1000...9000)
      )
    }
    self._caloricContributions = .constant(sampleData)
  }
  var body: some View {
    VStack {
      if !caloricContributions.isEmpty {
        SimpleContributionGraphView(
          content: caloricContributions.enumerated().map { (index, data) in
            HealthDataView(data: data, isToday: index == caloricContributions.count - 1)
          }
        )
      } else {
        Text("No data available. Please tap 'Update'.")
      }
    }
    .onAppear {
      healthKitFetcher.update()
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        self.caloricContributions = healthKitFetcher.dailyData
      }
    }
  }
}

// Other structs remain the same...

struct CaloriesGraphView_Previews: PreviewProvider {
  static var previews: some View {
    CaloriesGraphView()  // Using the initializer with sample data
  }
}

struct HealthDataView: View {
  var data: (caloriesBurned: Double, caloriesConsumed: Double)
  var isToday: Bool

  private var gradientRatio: CGFloat {
    guard data.caloriesConsumed > 0 else { return 1 }
    let ratio = data.caloriesBurned / data.caloriesConsumed
    return min(max(CGFloat(ratio), 0), 1)
  }

  var body: some View {
    let dominantColor: Color = data.caloriesBurned > data.caloriesConsumed ? .green : .gray

    let gradient = Gradient(stops: [
      .init(color: .green, location: 0),
      .init(color: .green, location: gradientRatio - 0.01),
      .init(color: .red, location: gradientRatio),
      .init(color: .red, location: 1),
    ])

    return Group {
      if isToday {
        LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)
      } else {
        dominantColor
      }
    }
    .frame(minWidth: 20, minHeight: 20)
    .cornerRadius(4)
  }
}
