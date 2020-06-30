//
//  JokesWidget.swift
//  JokesWidget
//
//  Created by Anupam Chugh on 30/06/20.
//

import WidgetKit
import SwiftUI

struct JokeProvider: TimelineProvider {
    public func snapshot(with context: Context, completion: @escaping (JokesEntry) -> ()) {
        let entry = JokesEntry(date: Date(), joke: "...")
        completion(entry)
    }

    public func timeline(with context: Context,
                         completion: @escaping (Timeline<Entry>) -> ()) {
        
        DataFetcher.shared.getJokes{
            response in

            let date = Date()
            let calendar = Calendar.current
                        
            let entries = response?.enumerated().map { offset, currentJoke in
                JokesEntry(date: calendar.date(byAdding: .second, value: offset, to: date)!, joke: currentJoke.joke ?? "...")
            }

            let timeLine = Timeline(entries: entries ?? [], policy: .atEnd)
            
            completion(timeLine)
            
        }
    }
}



struct JokesEntry: TimelineEntry {
    public let date: Date
    public let joke : String
}


struct JokesWidgetEntryView : View {
    var entry: JokeProvider.Entry

    var body: some View {
        Text(entry.joke)
            .minimumScaleFactor(0.3)
            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 5)
        
    }
}


struct JokesWidget: Widget {
    private let kind: String = "JokesWidget"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: JokeProvider(), placeholder: PlaceholderView()) { entry in
            JokesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Jokes Widget")
        .description("This is a widget ")
    }
}
