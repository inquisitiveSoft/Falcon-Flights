//
//  RootView.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 28/04/2022.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var flightManager: FlightManager = FlightManager()
    
    var body: some View {
        Group {
//            HeaderView()
            FalconListView()
        }
        .environmentObject(flightManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
