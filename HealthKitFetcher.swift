import HealthKit

class HealthKitFetcher: HealthKitFetching {
  private var healthStore: HKHealthStore?
  var dailyData: [(caloriesBurned: Double, caloriesConsumed: Double)] = []

  init() {
    if HKHealthStore.isHealthDataAvailable() {
      healthStore = HKHealthStore()
      update()
    }
  }

  func update() {
    guard let healthStore = healthStore else { return }

    let caloriesBurnedType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    let caloriesConsumedType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!

    dailyData = []

    for dayOffset in 0..<90 {  // Last 90 days
      let startOfDay = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())!
      let endOfDay = Calendar.current.date(byAdding: .day, value: -dayOffset + 1, to: Date())!

      let predicate = HKQuery.predicateForSamples(
        withStart: startOfDay, end: endOfDay, options: .strictStartDate)

      // Calorie intake query
      let caloriesQuery = HKStatisticsQuery(
        quantityType: caloriesConsumedType, quantitySamplePredicate: predicate,
        options: .cumulativeSum
      ) { [weak self] _, result, _ in
        guard let self = self, let result = result, let sum = result.sumQuantity() else {
          // Handle errors here.
          return
        }
        let caloriesConsumed = sum.doubleValue(for: HKUnit.kilocalorie())

        // Calorie burned query
        let burnedQuery = HKStatisticsQuery(
          quantityType: caloriesBurnedType, quantitySamplePredicate: predicate,
          options: .cumulativeSum
        ) { [weak self] _, result, _ in
          guard let self = self, let result = result, let sum = result.sumQuantity() else {
            // Handle errors here.
            return
          }
          let caloriesBurned = sum.doubleValue(for: HKUnit.kilocalorie())

          DispatchQueue.main.async {
            self.dailyData.append(
              (caloriesBurned: caloriesBurned, caloriesConsumed: caloriesConsumed))
          }
        }

        healthStore.execute(burnedQuery)
      }

      healthStore.execute(caloriesQuery)
    }
  }

  func fetchData(for month: Date, completion: @escaping () -> Void) {
    guard let healthStore = healthStore else { return }

    let startOfMonth = month.startOfMonth()
    let endOfMonth = month.endOfMonth()

    let caloriesBurnedType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    let caloriesConsumedType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!

    let predicate = HKQuery.predicateForSamples(
      withStart: startOfMonth, end: endOfMonth, options: .strictStartDate)

    // Clear existing data
    dailyData.removeAll()

    // Calorie intake query
    let caloriesQuery = HKStatisticsQuery(
      quantityType: caloriesConsumedType, quantitySamplePredicate: predicate,
      options: .cumulativeSum
    ) { [weak self] _, result, _ in
      guard let self = self, let result = result, let sum = result.sumQuantity() else {
        // Handle errors here.
        return
      }
      let caloriesConsumed = sum.doubleValue(for: HKUnit.kilocalorie())

      // Calorie burned query
      let burnedQuery = HKStatisticsQuery(
        quantityType: caloriesBurnedType, quantitySamplePredicate: predicate,
        options: .cumulativeSum
      ) { [weak self] _, result, _ in
        guard let self = self, let result = result, let sum = result.sumQuantity() else {
          // Handle errors here.
          return
        }
        let caloriesBurned = sum.doubleValue(for: HKUnit.kilocalorie())

        DispatchQueue.main.async {
          self.dailyData.append(
            (caloriesBurned: caloriesBurned, caloriesConsumed: caloriesConsumed))
        }
      }

      healthStore.execute(burnedQuery)
    }

    healthStore.execute(caloriesQuery)

    // Call the completion handler once all data for the month has been fetched
    completion()
  }

}

extension Date {
  func startOfMonth() -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month], from: self)
    return calendar.date(from: components)!
  }

  func endOfMonth() -> Date {
    let calendar = Calendar.current
    let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth())!
    return calendar.date(byAdding: .second, value: -1, to: startOfNextMonth)!
  }
}

class MockHealthKitFetcher: HealthKitFetching {
  var dailyData: [(caloriesBurned: Double, caloriesConsumed: Double)] = [
    // Add mock data here
    (caloriesBurned: 300, caloriesConsumed: 2500),
    (caloriesBurned: 500, caloriesConsumed: 2600),
    // ... more mock data ...
  ]

  func fetchData(for date: Date, completion: () -> Void) {
    // Immediately call completion handler with mock data
    completion()
  }
}

protocol HealthKitFetching {
  var dailyData: [(caloriesBurned: Double, caloriesConsumed: Double)] { get set }
  func fetchData(for date: Date, completion: @escaping () -> Void)
}
