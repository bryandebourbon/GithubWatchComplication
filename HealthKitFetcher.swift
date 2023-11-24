import HealthKit

class HealthKitFetcher {
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

    for dayOffset in 0..<28 {
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
}

class MockHealthKitFetcher: HealthKitFetcher {
  override init() {
    super.init()
    // Populate with sample data
    self.dailyData = (0..<28).map { _ in
      (
        caloriesBurned: Double.random(in: 200...500),
        caloriesConsumed: Double.random(in: 1500...2500)
      )
    }
  }
}
