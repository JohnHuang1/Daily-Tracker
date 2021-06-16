//
//  Counter_Widget.swift
//  Counter Widget
//
//  Created by John Huang on 6/7/21.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> TrackerEntry {
        TrackerEntry(date: Date(), configuration: ConfigurationIntent(), trackerItem: TrackerItem(name: "Workout", checked: true))
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (TrackerEntry) -> ()) {
        let entry = TrackerEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [TrackerEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = TrackerEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct TrackerEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let trackerItem: TrackerItem
}

struct Counter_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

@main
struct Counter_Widget: Widget {
    let kind: String = "Counter_Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Counter_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct Counter_Widget_Previews: PreviewProvider {
    static let trackerItem = TrackerItem(name: "Workout", checked: true)
    static var previews: some View {
        Counter_WidgetEntryView(entry: TrackerEntry(date: Date(), configuration: ConfigurationIntent(), trackerItem: trackerItem))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
