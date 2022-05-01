//
//  QueryRequestTypes.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 30/04/2022.
//

import Foundation

struct RequestBody: Codable {
    fileprivate var query: QueryBody?
    fileprivate var options: OptionsBody?
    
    init?(query: Query) {
        switch query {
        case .rocket(let rocket, pageNumber: let pageNumber):
            self.query = QueryBody(rocket: rocket.uuidString)
            
            if let pageNumber = pageNumber {
                self.options = OptionsBody(page: pageNumber)
            }
        }
    }
    
}

private struct QueryBody: Codable {
    var rocket: String?
}

// Ref: https://github.com/r-spacex/SpaceX-API/blob/master/docs/queries.md
//    select { Object | String } - Fields to return (by default returns all fields). Documentation
//    sort { Object | String } - Sort order. Documentation
//    offset { Number } - Use offset or page to set skip position
//    page { Number }
//    limit { Number }
//    pagination { Boolean } - If set to false, it will return all docs without adding limit condition. (Default: True)
//    populate {Array | Object | String} - Paths which should be populated with other documents. Documentation
private struct OptionsBody: Codable {
    var page: Int?
}
