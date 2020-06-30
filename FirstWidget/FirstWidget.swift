//
//  FirstWidget.swift
//  FirstWidget
//
//  Created by Anupam Chugh on 30/06/20.
//

import WidgetKit
import SwiftUI

struct CustomProvider: TimelineProvider {
    public func snapshot(with context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), covidCases: "...", covidRecovered: "...", covidDeaths: "...")
        completion(entry)
    }

    public func timeline(with context: Context,
                         completion: @escaping (Timeline<Entry>) -> ()) {
        
        DataFetcher.shared.fetchData{
            response in

            let date = Date()
            let calendar = Calendar.current
            
            let entry = SimpleEntry(date: calendar.date(byAdding: .hour, value: 0, to: date)!, covidCases: "\(response.0)", covidRecovered: "\(response.1)", covidDeaths: "\(response.2)")

            let timeLine = Timeline(entries: [entry], policy: .atEnd)
            
            completion(timeLine)
            
        }
    }
}



struct SimpleEntry: TimelineEntry {
    public let date: Date
    public let covidCases : String
    public let covidRecovered : String
    public let covidDeaths : String
    
}

public struct PlaceholderView : View {
    public var body: some View {
        Text("Placeholder View")
    }
}

struct FirstWidgetEntryView : View {
    var entry: CustomProvider.Entry

    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        
        switch family {
        
        case .systemLarge:
        
            VStack{
                Text((entry.date), style: .time)
                
                Text("COVID-19 World Data")
                    .font(.system(.headline, design: .rounded))
                    .padding()
                
                
                Text("Total Cases\n\(entry.covidCases)")
                    .font(.system(.headline, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding()
                Text("Total Recovered\n\(entry.covidRecovered)")
                    .font(.system(.headline, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding()
                Text("Total Deaths\n\(entry.covidDeaths)")
                    .font(.system(.headline, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color.pink)
        
        default:
            
            VStack{
                Text("COVID-19 World Data")
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.3)
                    .padding()

                Text("Total Cases")
                    .font(.system(.headline, design: .rounded))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.3)
                
                Text(entry.covidCases)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.3)
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color.pink)
            
            
        }
    }
}


struct FirstWidget: Widget {
    private let kind: String = "FirstWidget"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CustomProvider(), placeholder: PlaceholderView()) { entry in
            FirstWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("COVID-19 Widget")
        .description("This is a sample widget to track ongoing cases")
        
    }
}


@main
struct MyWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        FirstWidget()
        JokesWidget()
    }
}

