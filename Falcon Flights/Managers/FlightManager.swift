//
//  FlightManager.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 28/04/2022.
//

import Foundation

/// The core manager for the apps data
class FlightManager: ObservableObject {
    let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }
    
}
