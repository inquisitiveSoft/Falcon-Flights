//
//  PaginatedDataSource.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 01/05/2022.
//

import Foundation
import Combine
import SwiftUI

struct PaginatedListResult<ItemType> {
    var query: Query
    var next: Query?
    
    var items: [ItemType]
}

// Thie data source handles api paging
// and exposes the `launches` for the UI to bind to
class LaunchesDataSource: ObservableObject {
    let initialQuery: Query
    let sortOptions: SortOptions
    
    let networkManager: NetworkManager
    private var cancellable = Set<AnyCancellable>()
    
    @Published var isLoading: Bool = false
    @Published var launches: PaginatedListResult<RocketItem>?
    
    init(initialQuery: Query, sortOptions: SortOptions, networkManager: NetworkManager) {
        self.initialQuery = initialQuery
        self.sortOptions = sortOptions
        self.networkManager = networkManager
    }
    
    func loadNext() {
        let nextQuery = (launches != nil) ? launches?.next : initialQuery
        
        guard !isLoading, let nextQuery = nextQuery  else { return }
        isLoading = true
        
        networkManager.fetchQuery(nextQuery, sortOptions: sortOptions, itemType: ResponsePage<RocketItem>.self)
            .sink(receiveCompletion: { [weak self] completionResult in
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] (query: Query, page: ResponsePage<RocketItem>) in
                DispatchQueue.main.async {
                    self?.mergeResults(query: query, responsePage: page)
                }
            })
            .store(in: &cancellable)
    }
    
    func mergeResults(query: Query, responsePage: ResponsePage<RocketItem>) {
        var combinedItems = self.launches?.items ?? []
        combinedItems.append(contentsOf: responsePage.items)
//       combinedItems.sort { $0.flightNumber > $1.flightNumber }
        let nextQuery = responsePage.nextPage.flatMap { Query.rocket(.falcon9, pageNumber: $0) }

        launches = PaginatedListResult<RocketItem>(query: query, next: nextQuery, items: combinedItems)
    }
    
}
