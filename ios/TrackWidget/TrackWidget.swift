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
    func placeholder(in context: Context) -> TrackerEntry {
        print("--------------- placeholder called ---------------")
        return TrackerEntry(date: Date(), configuration: SingleCounterIntent(), streakItem: StreakItem(name: "Default", prevHighestStreak: 0, currHighestStreak: 0, checked: true))
    }

    func getSnapshot(for configuration: SingleCounterIntent, in context: Context, completion: @escaping (TrackerEntry) -> ()) {
        print("--------------- getSnapshot called ---------------")
        let entry = TrackerEntry(date: Date(), configuration: configuration, streakItem: StreakItem(name: "Default", prevHighestStreak: 0, currHighestStreak: 0, checked: true))
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
                    flutterData = try decoder.decode(FlutterWidgetData.self, from: shared!.data(using: .utf8)!)
                    print("Flutter data decoded----------------------")
                    flutterData?.streakList.forEach{ item in
                        print("\t------Item: " + item.name + " " + String(item.checked))
                    }
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
        print("flutterData.streakList.isEmpty = " + String(flutterData!.streakList.isEmpty))

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = TrackerEntry(date: entryDate, configuration: configuration, streakItem: flutterData!.streakList[index!])
            
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct TrackerEntry: TimelineEntry {
    let date: Date
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
            TrackWidgetEntryView(entry: TrackerEntry(date: Date(), configuration: SingleCounterIntent(), streakItem: StreakItem(name: "Default", prevHighestStreak: 0, currHighestStreak: 0, checked: true)))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            TrackWidgetEntryView(entry: TrackerEntry(date: Date(), configuration: SingleCounterIntent(), streakItem: StreakItem(name: "Default", prevHighestStreak: 0, currHighestStreak: 0, checked: true)))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
