//
//  ListView.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 28/04/2022.
//

import SwiftUI
import Combine
import AsyncImage

// Not sure how I feel about extending CGFloat in this way
// a bit of an experiment
extension CGFloat {
    static var padding: CGFloat { return 8 }
    static var cornerRadius: CGFloat { return 8 }
}

struct FalconListView: View {
    @EnvironmentObject var flightManager: FlightManager
    @State private var isLoading: Bool = false
    @State private var rocketResults: PaginatedListResult<RocketItem>?
    @State private var cancellable = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            if let rocketResults = rocketResults {
                ScrollView {
                    ForEach(rocketResults.items) { (item) in
                        RocketListViewItem(item: item)
                    }
                    
                    // Show a loading indicator when loading the next page of data
                    if isLoading {
                        Text("Loading")
                    }
                }
            } else if isLoading {
                LoadingView()
            }
        }
        .onAppear {
            loadNext()
        }
    }
    
    func loadNext() {
        guard !isLoading else { return }
            
        withAnimation {
            isLoading = true
        }
        
        flightManager.networkManager.fetchQuery(.rocket(.falcon9, pageNumber: nil), itemType: ResponsePage<RocketItem>.self)
            .sink(receiveCompletion: { completionResult in
                withAnimation {
                    isLoading = false
                }
            }, receiveValue: { (query, rocketPage) in
                let nextQuery = rocketPage.nextPage.flatMap { Query.rocket(.falcon9, pageNumber: $0) }
                var combinedItems = (rocketResults?.items ?? []) + rocketPage.items
                combinedItems.sort { $0.date > $1.date }

                withAnimation {
                    rocketResults = PaginatedListResult<RocketItem>(query: query,
                                                                    next: nextQuery,
                                                                    items: combinedItems)
                }
            })
            .store(in: &cancellable)
    }

}

struct LoadingView: View {
    
    var body: some View {
        if #available(iOS 14.0, *) {
            ProgressView()
        } else {
            Text("Loading")
        }
    }
    
}

struct RocketListViewItem: View {
    var item: RocketItem
    
    var body: some View {
        ZStack {
            VStack {
                AsyncImage(url: item.imageURLs.first) { image in
                    image
                } placeholder: {
                    Image("Nebula00\(Int.random(in: 1..<4))")
                }
                .padding(.padding)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadius))
        }
    }
    
}
