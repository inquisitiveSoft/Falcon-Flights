//
//  GenericResponseDataTypes.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 02/05/2022.
//  This code is available under the MIT license: https://opensource.org/licenses/MIT
//

import Foundation

/// A generic type that can be used for SpaceX api endpoints
/// that return paged data
struct ResponsePage<Item: Decodable>: Decodable {
    private enum CodingKeys: String, CodingKey {
        case hasNextPage
        case nextPage
        case items = "docs"
    }
    
    var items: [Item]
    
    var hasNextPage: Bool
    var nextPage: Int?
}
