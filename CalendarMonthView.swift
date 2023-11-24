import HealthKit
import SwiftUI

struct CalendarMonthView: View {
  @Binding var caloricContributions: [(caloriesBurned: Double, caloriesConsumed: Double)]
  var healthKitFetcher = HealthKitFetcher()

  init(caloricContributions: Binding<[(caloriesBurned: Double, caloriesConsumed: Double)]>) {
    self._caloricContributions = caloricContributions
  }

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
          originalContent: caloricContributions.enumerated().map { (index, data) in
            // TODO: change to DataView
            HealthDataView(data: data, isToday: index == caloricContributions.count - 1)
          }, defaultView: HealthDataView(data: (0, 0), isToday: false)
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

struct CalendarMonthView_Previews: PreviewProvider {
  static var previews: some View {
    CalendarMonthView()  // Using the initializer with sample data
  }
}

struct DataView: View {
  var data: (caloriesBurned: Double, caloriesConsumed: Double)
  var isToday: Bool
    //TODO: threshold function
  var thresholdFunction: (Double, Double) -> Double  // New parameter for the threshold function

  private var gradientRatio: CGFloat {
    guard data.caloriesConsumed > 0 else { return 1 }
    let ratio = data.caloriesBurned / data.caloriesConsumed
    return min(max(CGFloat(ratio), 0), 1)
  }

  private var alphaValue: Double {
    thresholdFunction(data.caloriesBurned, data.caloriesConsumed)
  }

  var body: some View {
    let dominantColor: Color = (data.caloriesBurned > data.caloriesConsumed ? Color.green : .gray)
      .opacity(alphaValue)

    let gradient = Gradient(stops: [
      .init(color: .green.opacity(alphaValue), location: 0),
      .init(color: .green.opacity(alphaValue), location: gradientRatio - 0.01),
      .init(color: .red.opacity(alphaValue), location: gradientRatio),
      .init(color: .red.opacity(alphaValue), location: 1),
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
