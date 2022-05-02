//
//  FlightManager.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 28/04/2022.
//  This code is available under the MIT license: https://opensource.org/licenses/MIT
//

import Foundation

/// The core manager for the apps data
class FlightManager: ObservableObject {
    let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }
    
}
