//
//  QueryRequestTypes.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 30/04/2022.
//  This code is available under the MIT license: https://opensource.org/licenses/MIT
//

import Foundation

/// Used for building a request body
struct RequestBody: Codable {
    fileprivate var query: QueryBody?
    fileprivate var options: OptionsBody?
    
    init?(query: LaunchesQuery, sortOptions: SortOptions) {
        switch query {
        case .rocket(let rocket, pageNumber: let pageNumber):
            self.query = QueryBody(rocket: rocket.uuidString, upcoming: false)
            self.options = OptionsBody(page: pageNumber, sort: sortOptions)
        }
    }
    
}

/// Query parameters
/// Ref: https://github.com/r-spacex/SpaceX-API/blob/master/docs/queries.md
private struct QueryBody: Codable {
    var rocket: String?
    var upcoming: Bool?
}

/**
# Available options:
  select { Object | String } - Fields to return (by default returns all fields). Documentatio
 sort { Object | String } - Sort order. Documentation
 offset { Number } - Use offset or page to set skip position
 page { Number }
 limit { Number }
 pagination { Boolean } - If set to false, it will return all docs without adding limit condition. (Default: True)
 populate {Array | Object | String} - Paths which should be populated with other documents. Documentation

 Ref: https://github.com/r-spacex/SpaceX-API/blob/master/docs/queries.md
*/
private struct OptionsBody: Codable {
    var page: Int?
    var sort: [String: SortDirection]?
}

typealias SortOptions = [String: SortDirection]

enum SortDirection: String, Codable {
    case ascending
    case descending
}
