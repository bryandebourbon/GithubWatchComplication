//import HealthKit
//import SwiftUI
//
//struct CalendarMonthView: View {
//  @Binding var caloricContributions: [(caloriesBurned: Double, caloriesConsumed: Double)]
//  var healthKitFetcher = HealthKitFetcher()
//
//  init(caloricContributions: Binding<[(caloriesBurned: Double, caloriesConsumed: Double)]>) {
//    self._caloricContributions = caloricContributions
//  }
//
//  init() {
//    let calendar = Calendar.current
//    let currentDate = Date()
//
//    // Get the current day of the month
//      let dayOfMonth = calendar.component(.day, from: currentDate)
//
//    // Generate sample data up to the current day of the month
//    let sampleData = (0..<dayOfMonth).map { _ in
//      (
//        caloriesBurned: Double.random(in: 1000...6000),
//        caloriesConsumed: Double.random(in: 1000...9000)
//      )
//    }
//
//    self._caloricContributions = .constant(sampleData)
//  }
//
//  var body: some View {
//    VStack {
//      if !caloricContributions.isEmpty {
//        let currentDayOfMonth = Calendar.current.component(.day, from: Date())  // Get the current day of the month
//        SimpleContributionGraphView(
//          originalContent: caloricContributions.enumerated().map { (index, data) in
//            DataView(
//              data: data,
//              isToday: index + 1 == currentDayOfMonth,
//              isInFuture: index + 1 > currentDayOfMonth,
//              thresholdFunction: { burned, consumed in
//                burned > consumed ? 1.0 : 0.5
//              }
//            )
//          },
//          defaultView: DataView(
//            data: (0, 0),
//            isToday: false, isInFuture: true,
//            thresholdFunction: { _, _ in 1.0 }  // Default threshold function for default views
//          )
//        )
//      } else {
//        Text("No data available. Please tap 'Update'.")
//      }
//    }
//
//    .onAppear {
//      healthKitFetcher.update()
//      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//        self.caloricContributions = healthKitFetcher.dailyData
//      }
//    }
//  }
//}
//
//struct DataView: View {
//  var data: (caloriesBurned: Double, caloriesConsumed: Double)
//  var isToday: Bool
//  var isInFuture: Bool  // Property to indicate if the day is in the future
//  var thresholdFunction: (Double, Double) -> Double
//
//  private var gradientRatio: CGFloat {
//    guard data.caloriesConsumed > 0 else { return 1 }
//    let ratio = data.caloriesBurned / data.caloriesConsumed
//    return min(max(CGFloat(ratio), 0), 1)
//  }
//
//  var body: some View {
//    var dominantColor = data.caloriesBurned > data.caloriesConsumed ? Color.green : Color.red.opacity(0.4)
//      if isInFuture {
//          dominantColor = Color.gray.opacity(0.4)
//      }
//
//    let gradient = Gradient(stops: [
//      .init(color: .green, location: 0),
//      .init(color: .green, location: gradientRatio - 0.01),
//      .init(color: .red, location: gradientRatio),
//      .init(color: .red, location: 1),
//    ])
//
//    return Group {
//      if isToday {
//        LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)
//      } else {
//        dominantColor
//      }
//    }
//    .frame(minWidth: 20, minHeight: 20)
//    .cornerRadius(4)
//  }
//}
//
//
//// Other structs remain the same...
//
//struct CalendarMonthView_Previews: PreviewProvider {
//  static var previews: some View {
//    CalendarMonthView()
//      .frame(width: 200, height: 60)
//  }
//}
