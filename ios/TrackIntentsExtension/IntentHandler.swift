//
//  IntentHandler.swift
//  TrackIntentsExtension
//
//  Created by John Huang on 6/17/21.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        print("--------------- handler called ---------------")
        
        return self
    }
    
}

extension IntentHandler: SingleCounterIntentHandling{
    enum DateError: String, Error {
        case invalidDate
    }
    func provideTrackerOptionsCollection(for intent: SingleCounterIntent, with completion: @escaping (INObjectCollection<Tracker>?, Error?) -> Void) {
        print("------- provideTrackerOptionsCollection called ----------")
        let sharedDefaults = UserDefaults.init(suiteName: "group.com.dailytracker")
        
        var flutterData: FlutterWidgetData? = nil
        var items: [Tracker] = []

        if(sharedDefaults != nil){
            do{
                let shared = sharedDefaults?.string(forKey: "widgetData")
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
                } else {
                    print("Shared nil----------------------------")
                }
                items = flutterData!.streakList.map{ item in
                    let tracker = Tracker(identifier: String(flutterData!.streakList.distance(from: flutterData!.streakList.startIndex, to: flutterData!.streakList.firstIndex(of: item)!)), display: item.name)
                    print("------Tracker " + tracker.identifier! + " " + tracker.displayString)
                    return tracker
                }
            }
            catch{
                print(error.localizedDescription + "---------------------------")
            }
        } else {
            print("Shared Defaults nil--------------------------------")
        }
        print("items.isEmpty = " + String(items.isEmpty))
        let collection = INObjectCollection(items: !items.isEmpty ? items : [Tracker(identifier: "0", display: "Default")] )
        print("--------- collection set --------------- ")
        completion(collection, nil)
    }
    func defaultTracker(for intent: SingleCounterIntent) -> Tracker? {
        return Tracker(identifier: "0", display: "Default")
    }
}
