//
//  PaginatedDataSource.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 01/05/2022.
//

import Foundation

struct PaginatedListResult<ItemType> {
    var query: Query
    var next: Query?
    
    var items: [ItemType]
}
