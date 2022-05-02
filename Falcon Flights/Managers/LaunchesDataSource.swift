//
//  PaginatedDataSource.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 01/05/2022.
//  This code is available under the MIT license: https://opensource.org/licenses/MIT
//

import Foundation
import Combine
import SwiftUI

/// Stores a list of items, along with the last query, and a next query if it exists
/// PaginatedListResult is only semi-generic, as the LaunchesQuery is specialised for the /launches endpoint
struct PaginatedListResult<ItemType> {
    var query: LaunchesQuery
    var next: LaunchesQuery?
    
    var items: [ItemType]
}

// Thie data source handles api paging and
// exposes the data for the UI to bind to
class LaunchesDataSource: ObservableObject {
    let initialQuery: LaunchesQuery
    let sortOptions: SortOptions
    
    private let networkManager: NetworkManager
    private var cancellable = Set<AnyCancellable>()
    
    @Published var isLoading: Bool = false
    @Published var lastRequestFailed: Bool = false  // Used to show a reload control
    @Published var launches: PaginatedListResult<LaunchItem>?
    
    init(initialQuery: LaunchesQuery, sortOptions: SortOptions, networkManager: NetworkManager) {
        self.initialQuery = initialQuery
        self.sortOptions = sortOptions
        self.networkManager = networkManager
    }
    
    func loadNext() {
        let nextQuery = (launches != nil) ? launches?.next : initialQuery
        
        guard !isLoading, let nextQuery = nextQuery  else { return }
        
        lastRequestFailed = false
        isLoading = true
        
        networkManager.fetchQuery(nextQuery, sortOptions: sortOptions, itemType: ResponsePage<LaunchItem>.self)
            .sink(receiveCompletion: { [weak self] completionResult in
                DispatchQueue.main.async {
                    self?.didCompleteRequest(completionResult)
                }
            }, receiveValue: { [weak self] (query: LaunchesQuery, page: ResponsePage<LaunchItem>) in
                DispatchQueue.main.async {
                    self?.mergeResults(query: query, responsePage: page)
                }
            })
            .store(in: &cancellable)
    }
    
    private func didCompleteRequest(_ completionResult: Subscribers.Completion<NetworkManager.APIError>) {
        isLoading = false

        switch completionResult {
        case .finished:
            break

        case .failure(let error):
            // Log error
            print("network error: \(error)")
            
            lastRequestFailed = true
        }
    }
    
    private func mergeResults(query: LaunchesQuery, responsePage: ResponsePage<LaunchItem>) {
        // Combine the new page with the existing launch items
        var combinedItems = self.launches?.items ?? []
        combinedItems.append(contentsOf: responsePage.items)
        
        // Store the next query if there is one
        let nextQuery = responsePage.nextPage.flatMap { LaunchesQuery.rocket(.falcon9, pageNumber: $0) }

        launches = PaginatedListResult<LaunchItem>(query: query, next: nextQuery, items: combinedItems)
    }
    
}
