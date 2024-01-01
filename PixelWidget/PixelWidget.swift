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

  func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
    SimpleEntry(date: Date(), configuration: configuration)
  }

  func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
    SharedUserDefaults.shared.updateData{ return }

    // Fetch contribution and event days
    let sharedContributionDays = SharedUserDefaults.shared.getContributionDays()
    let sharedEventDays = SharedUserDefaults.shared.getEventDays()

    var entries: [SimpleEntry] = []


    let entry = SimpleEntry(
      date: Date(),
      configuration: configuration,
      sharedArray: sharedContributionDays,
      eventDays: sharedEventDays  // New Line
    )
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
  let eventDays: [EventCountDay]  // Add this line

  init(date: Date, configuration: ConfigurationAppIntent, sharedArray: [ContributionDay] = [], eventDays: [EventCountDay] = []) {
    self.date = date
    self.configuration = configuration
    self.sharedArray = sharedArray
    self.eventDays = eventDays  // Add this line
  }
}


struct PixelWidgetEntryView: View {
  let entry: SimpleEntry


  var body: some View {
    VStack {
      GitHubMonthView(contributions: .constant(entry.sharedArray),  eventDays: .constant(entry.eventDays))
    }.containerBackground(for:.widget){
        Color.black
    }.frame(width: 194, height: 76)
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



struct PixelWidget_Previews: PreviewProvider {
  static var sampleData: [ContributionDay] = ContributionsModel().generateMockDataMonth()
  static var sampleEventDays: [EventCountDay] = SharedUserDefaults.shared.getEventDays()  // New Line

  static var previews: some View {
    PixelWidgetEntryView(
      entry: SimpleEntry(
        date: Date(),
        configuration: .smiley,
        sharedArray: sampleData,
        eventDays: sampleEventDays  // New Line
      )
    )
    .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
  }
}

