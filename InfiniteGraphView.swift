//import SwiftUI
//
//struct InfiniteGraphView: View {
//  @State private var displayedMonths: [MonthData] = []
//  @State private var isLoadingData = false
//  var healthKitFetcher: HealthKitFetching
//
//  // Add a computed property to generate month names based on displayedMonths
//  var displayedMonthNames: [String] {
//    displayedMonths.map { monthData in
//      let dateFormatter = DateFormatter()
//      dateFormatter.dateFormat = "MMM"
//      return dateFormatter.string(from: monthData.month)
//    }
//  }
//
//  var body: some View {
//    GeometryReader { geometry in
//      ScrollView {
//        LazyVStack {
//          if displayedMonths.isEmpty {
//            Text("No data available")
//          } else {
//            ForEach(Array(displayedMonths.enumerated()), id: \.element.month) {
//              (index, monthData) in
//              // Text(displayedMonthNames[index]) // Comment out displaying the month name
//
//              MonthGraphView(monthData: monthData, monthName: displayedMonthNames[index]) // Pass the MonthData and monthName
//                .frame(width: geometry.size.width, height: 100)
//                .onAppear {
//                  loadMoreData()
//                }
//            }
//
//            if isLoadingData {
//              ProgressView()
//            }
//          }
//        }
//      }
//      .onAppear {
//        loadInitialData()
//      }
//    }
//  }
//
//  private func loadInitialData() {
//    isLoadingData = true
//    let currentMonth = Date()
//    healthKitFetcher.fetchData(for: currentMonth) {
//      var newDisplayedMonths = [MonthData]()
//      let calendar = Calendar.current
//      let components = calendar.dateComponents([.year, .month], from: currentMonth)
//      let startOfMonth = calendar.date(from: components)!
//      let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
//
//      // Create an array of `DayData` for each day in the current month.
//      var dailyDataArray: [DayData] = []
//      for dayOffset in 0..<range.count {
//        let day = calendar.date(byAdding: .day, value: dayOffset, to: startOfMonth)!
//        // We are assuming that the `dailyData` array has data ordered by day.
//        if dayOffset < self.healthKitFetcher.dailyData.count {
//          let dataForDay = self.healthKitFetcher.dailyData[dayOffset]
//          let dayData = DayData(
//            day: day, caloriesBurned: dataForDay.caloriesBurned,
//            caloriesConsumed: dataForDay.caloriesConsumed)
//          dailyDataArray.append(dayData)
//        } else {
//          // If there is no data for this day, you might want to add a placeholder or fetch the data if needed.
//          dailyDataArray.append(DayData(day: day, caloriesBurned: 0, caloriesConsumed: 0))
//        }
//      }
//
//      // Add the new month data to the front of the displayed months array.
//      newDisplayedMonths.append(MonthData(month: startOfMonth, dailyData: dailyDataArray))
//
//      // Update the state with the new data.
//      DispatchQueue.main.async {
//        self.displayedMonths = newDisplayedMonths
//        self.isLoadingData = false
//      }
//    }
//  }
//
//  private func loadMoreData() {
//    guard !isLoadingData, let firstMonth = displayedMonths.first?.month else { return }
//    isLoadingData = true
//
//    // Calculate the previous month based on the first month in your array.
//    let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: firstMonth)!
//
//    // Fetch data for the previous month.
//    healthKitFetcher.fetchData(for: previousMonth) {
//      // After fetching the data, create the MonthData for the previous month.
//      // This assumes that `fetchData` updates the `dailyData` property of the fetcher.
//      var dailyDataForPreviousMonth: [DayData] = []
//      let calendar = Calendar.current
//      let daysInPreviousMonth =
//        calendar.range(of: .day, in: .month, for: previousMonth)?.count ?? 30
//
//      // Map the fetched data to your DayData structure.
//      for dayOffset in 0..<daysInPreviousMonth {
//        if dayOffset < self.healthKitFetcher.dailyData.count {
//          let dayDataTuple = self.healthKitFetcher.dailyData[dayOffset]
//          let day = calendar.date(
//            byAdding: .day, value: dayOffset, to: previousMonth.startOfMonth())!
//          let dayData = DayData(
//            day: day, caloriesBurned: dayDataTuple.caloriesBurned,
//            caloriesConsumed: dayDataTuple.caloriesConsumed)
//          dailyDataForPreviousMonth.append(dayData)
//        }
//      }
//
//      let newMonthData = MonthData(month: previousMonth, dailyData: dailyDataForPreviousMonth)
//
//      // Update the state with the new data.
//      DispatchQueue.main.async {
//        self.displayedMonths.insert(newMonthData, at: 0)
//        self.isLoadingData = false
//      }
//    }
//  }
//}
//
//struct MonthData {
//  let month: Date  // Represents the first day of the month
//  var dailyData: [DayData]  // Array of data for each day in the month
//}
//
//struct DayData {
//  let day: Date  // Represents a specific day
//  let caloriesBurned: Double
//  let caloriesConsumed: Double
//}
//
//// Define MonthGraphView, DayHeadersView, and other necessary views here...
//
//struct InfiniteGraphView_Previews: PreviewProvider {
//  static var previews: some View {
//    InfiniteGraphView(healthKitFetcher: MockHealthKitFetcher())
//      .frame(width: 300, height: 600)  // Adjust the height to show more content if needed
//  }
//}
