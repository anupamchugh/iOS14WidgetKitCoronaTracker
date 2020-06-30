//
//  ContentView.swift
//  iOS14WidgetKit
//
//  Created by Anupam Chugh on 30/06/20.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    
    @ObservedObject var coronaCases = DataFetcher()
    
    var body: some View {
        VStack{
            
            Text("COVID-19 World Data")
                .font(.system(.headline, design: .rounded))
                .padding()
            
            VStack{
                Text("Total Cases\n\(coronaCases.coronaOutbreak.totalCases)")
                    .multilineTextAlignment(.center)
                    .padding()

                Text("Total Recovered\n\(coronaCases.coronaOutbreak.totalRecovered)")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("Total Deaths\n\(coronaCases.coronaOutbreak.totalDeaths)")
                    .multilineTextAlignment(.center)
                    .padding()
                
            }
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.pink))
            .shadow(color: .pink, radius: 20)
            .padding()
            
            Button(action: {WidgetCenter.shared.reloadAllTimelines()}, label: {
                Text("Reload All Timelines")
            })
        }
        .onAppear {
            coronaCases.fetchCoronaCases()
        }
        
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
