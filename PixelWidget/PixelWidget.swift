//
//  PixelWidget.swift
//  PixelWidget
//
//  Created by Bryan de Bourbon on 11/20/23.
//

import SwiftUI
import WidgetKit

struct Provider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
  }

  func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry
  {
    SimpleEntry(date: Date(), configuration: configuration)
  }

  func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<
    SimpleEntry
  > {
    var entries: [SimpleEntry] = []

    let entry = SimpleEntry(
      date: Date(), configuration: configuration,
      sharedArray: SharedUserDefaults.shared.getSharedArray())
    entries.append(entry)

    let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    return Timeline(entries: entries, policy: .after(refreshDate))
  }

  func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
    // Create an array with all the preconfigured widgets to show.
    [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "Example Widget")]
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationAppIntent
  let sharedArray: [ContributionDay]
//  var contributions = []

  init(date: Date, configuration: ConfigurationAppIntent, sharedArray: [ContributionDay] = []) {
    self.date = date
    self.configuration = configuration
    self.sharedArray = sharedArray
  }
}

struct PixelWidgetEntryView: View {
  let entry: SimpleEntry


  var body: some View {
    VStack {
//        CalendarMonthView()
    }.containerBackground(for: .widget){
        Color.black
    }
  }
}
@main
struct PixelWidget: Widget {
  let kind: String = "PixelWidget"

  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) {
      entry in
      PixelWidgetEntryView(entry: entry)
    }
  }
}

extension ConfigurationAppIntent {
  fileprivate static var smiley: ConfigurationAppIntent {
    let intent = ConfigurationAppIntent()
    intent.favoriteEmoji = "😀"
    return intent
  }

  fileprivate static var starEyes: ConfigurationAppIntent {
    let intent = ConfigurationAppIntent()
    intent.favoriteEmoji = "🤩"
    return intent
  }
}

var model = ContributionsModel()  // Make 'model' static
var sampleData: [ContributionDay] = model.generateMockData()

struct PixelWidget_Previews: PreviewProvider {
    
    static var previews: some View {
        PixelWidgetEntryView(
            entry: SimpleEntry(
                date: Date(),
                configuration: .smiley,
                sharedArray: sampleData
            )
        )
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
