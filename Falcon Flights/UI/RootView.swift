//
//  RootView.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 28/04/2022.
//  This code is available under the MIT license: https://opensource.org/licenses/MIT
//

import SwiftUI

struct RootView: View {
    @ObservedObject var flightManager: FlightManager
    @ObservedObject var dataSource: LaunchesDataSource
    
    init(flightManager: FlightManager = FlightManager()) {
        self.flightManager = flightManager
        
        dataSource = LaunchesDataSource(initialQuery: .rocket(.falcon9, pageNumber: nil),
                                        sortOptions: ["flight_number": .ascending],
                                        networkManager: flightManager.networkManager)
    }
    
    var body: some View {
        Group {
            FalconListView(dataSource: dataSource)
        }
        .environmentObject(flightManager)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
