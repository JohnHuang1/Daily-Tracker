//
//  TrackWidget.swift
//  TrackWidget
//
//  Created by John Huang on 6/17/21.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    enum DateError: String, Error {
        case invalidDate
    }
    func placeholder(in context: Context) -> TrackerEntry {
        print("--------------- placeholder called ---------------")
        return TrackerEntry(date: Date(), lastUpdated: Date(), configuration: SingleCounterIntent(), streakItem: StreakItem(name: "Default", prevHighestStreak: 0, currHighestStreak: 0, checked: true))
    }

    func getSnapshot(for configuration: SingleCounterIntent, in context: Context, completion: @escaping (TrackerEntry) -> ()) {
        print("--------------- getSnapshot called ---------------")
        let entry = TrackerEntry(date: Date(), lastUpdated: Date(),  configuration: configuration, streakItem: StreakItem(name: "Default", prevHighestStreak: 0, currHighestStreak: 0, checked: true))
        completion(entry)
    }

    func getTimeline(for configuration: SingleCounterIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        print("--------------- getTimeline called ---------------")
        var entries: [TrackerEntry] = []
        
        let index = Int((configuration.tracker?.identifier)!)
        
        print("----------- index retrieved ---------- ")
        
        let sharedDefaults = UserDefaults.init(suiteName: "group.com.dailytracker")
        var flutterData: FlutterWidgetData? = nil
        
        if(sharedDefaults != nil){
            do{
                let shared = sharedDefaults?.string(forKey: "widgetData")
                print("shared = " + (shared ?? "nil"))
                if(shared != nil){
                    let decoder = JSONDecoder()
//                    decoder.dateDecodingStrategy = .iso8601
                    let formatter = DateFormatter()
                    formatter.calendar = Calendar(identifier: .iso8601)
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)

                    decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
                        let container = try decoder.singleValueContainer()
                        let dateStr = try container.decode(String.self)

                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                        if let date = formatter.date(from: dateStr) {
                            return date
                        }
                        throw DateError.invalidDate
                    })
                    
                    flutterData = try decoder.decode(FlutterWidgetData.self, from: shared!.data(using: .utf8)!)
                    print("Flutter data decoded----------------------")
                    let format = DateFormatter()
                    format.dateFormat = "YY, MMM d, HH:mm:ss"
                    print("lastUpdated: " + format.string(from: flutterData!.lastUpdated))
                    print("Date(): " + format.string(from: Date()))
                } else {
                    print("Shared nil----------------------------")
                }
            }
            catch{
                print(error)
            }
        } else {
            print("Shared Defaults nil--------------------------------")
        }
        if flutterData != nil {
            print("flutterData.streakList.isEmpty = " + String(flutterData!.streakList.isEmpty))
            let updated = Calendar.current.compare(flutterData!.lastUpdated, to: Date(), toGranularity: .day)
            if updated == .orderedAscending {
                print("updated == .orderedAscending true ---------")
                if flutterData!.streakList[index!].checked == false || Calendar.current.compare(Calendar.current.date(byAdding: .day, value: 1, to: flutterData!.lastUpdated)!, to: Date(), toGranularity: .day) == .orderedAscending {
                    print("reset streaks reached---------------- ")
                    let curr = flutterData!.streakList[index!].currHighestStreak
                    let prev = flutterData!.streakList[index!].prevHighestStreak
                    if curr > prev {
                        flutterData!.streakList[index!].prevHighestStreak = curr
                    }
                    flutterData!.streakList[index!].currHighestStreak = 0
                }
                flutterData!.streakList[index!].checked = false
            }
        }

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 26{
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = TrackerEntry(date: entryDate, lastUpdated: flutterData!.lastUpdated, configuration: configuration, streakItem: flutterData!.streakList[index!])
            
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct TrackerEntry: TimelineEntry {
    let date: Date
    let lastUpdated: Date
    let configuration: SingleCounterIntent
    let streakItem: StreakItem
}

struct TrackWidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family{
        case .systemSmall:
            VStack(spacing: 5){
                Color("widgetBackground")
                Text(entry.streakItem.name).font(.title).truncationMode(.tail).lineLimit(1)
                Image(entry.streakItem.checked ? "checkbox_48" : "checkbox_outline_48").resizable().frame(width: 100, height: 100).foregroundColor(Color("accent")).padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                Text(DateFormatter().string(from: entry.lastUpdated)).padding(EdgeInsets(top: -30, leading: 0, bottom: 10, trailing: 0))
            }
        default:
            VStack(spacing: 7){
                Color("widgetBackground")
                Text(entry.streakItem.name).font(.title).truncationMode(.tail).lineLimit(1).padding(EdgeInsets(top:0, leading: 0, bottom: -10, trailing: 0))
                HStack(spacing: 20){
                    VStack(alignment: .leading, spacing: 0){
                        HStack{
                            Text("Current Streak:").font(.headline)
                            Text(String(entry.streakItem.currHighestStreak)).bold().foregroundColor(Color("accent")).font(.system(size: 30))
                        }.padding(EdgeInsets(top:0, leading: 0, bottom: 10, trailing: 0))
                        HStack{
                            Text("Previous Highest:").font(.headline)
                            Text(String(entry.streakItem.prevHighestStreak)).bold().foregroundColor(Color("accent")).font(.system(size: 30))
                        }
                    }
                Image(entry.streakItem.checked ? "checkbox_48" : "checkbox_outline_48").resizable().frame(width: 120, height: 120).foregroundColor(Color("accent"))
                }
            }
        }
    }
}

@main
struct TrackWidget: Widget {
    let kind: String = "TrackWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SingleCounterIntent.self, provider: Provider()) { entry in
            TrackWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TrackWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            TrackWidgetEntryView(entry: TrackerEntry(date: Date(),lastUpdated: Date(), configuration: SingleCounterIntent(), streakItem: StreakItem(name: "Default", prevHighestStreak: 0, currHighestStreak: 0, checked: true)))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            TrackWidgetEntryView(entry: TrackerEntry(date: Date(),lastUpdated: Date(), configuration: SingleCounterIntent(), streakItem: StreakItem(name: "Default", prevHighestStreak: 0, currHighestStreak: 0, checked: true)))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
