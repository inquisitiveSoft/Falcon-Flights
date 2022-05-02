//
//  FlightNetworkManager.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 29/04/2022.
//  This code is available under the MIT license: https://opensource.org/licenses/MIT
//

import Foundation
import Combine

/// Creating a protocol to allow a mock object to be injected in URLSession's place for testing
protocol URLSessionProtocol {
    // This mirrors an existing function of URLSession
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher
}

extension URLSession: URLSessionProtocol {}

/// Handles calls to the SpaceX api
class NetworkManager {
    // Having a general APIError type is helpful
    // for getting Combine to work nicely with error types
    enum APIError: Error {
        case decodingError(DecodingError)
        case unknownError(Error)
    }
    
    // Force-unwrapping here as IMO it's better to fail early
    // (hopefully in integration testing) if the URL is invalid.
    private let apiRootURL: URL = URL(string: "https://api.spacexdata.com/v5")!
    private let urlSession: URLSessionProtocol
    
    // Decoder used for parsing the response JSON
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        
        // In theory the api returns iso8601 dates but it
        // doesn't seem to decode, so using a custom date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return decoder
    }()

    init(urlSession: URLSessionProtocol = URLSession(configuration: .default)) {
        self.urlSession = urlSession
    }
    
    // Item.type parameter here is unfortunately necessary to specialise the generic function
    func fetchQuery<Item: Decodable>(_ query: LaunchesQuery, sortOptions: SortOptions, itemType: Item.Type) -> AnyPublisher<(LaunchesQuery, Item), APIError> {
        // Create the request
        let url = query.url(withAPIRoot: apiRootURL)
        var request =  URLRequest(url: url)
        request.httpMethod = query.httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let requestBody = RequestBody(query: query, sortOptions: sortOptions) {
            request.httpBody = try? JSONEncoder().encode(requestBody)
        }
        
        // Create the publisher that will perform the request
        let publisher = urlSession.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Item.self, decoder: decoder)
            .map { item in
                // Returning the query along with the data
                // as that can be used for paging
                return (query, item)
            }
            .mapError { APIError(error: $0) }
            .eraseToAnyPublisher()
        
        return publisher
    }

}

/// Extension to log errors and convert to a unified error type
extension NetworkManager.APIError {
    
    init(error: Error) {
        // Mapping errors like this helps work around Combine types
        if let error = error as? DecodingError {
//            switch error {
//            case .typeMismatch(let any, let decodingError):
//                print("typeMismatch: \(any), \(decodingError)")
//
//            case .valueNotFound(let any, let decodingError):
//                print("valueNotFound: \(any), \(decodingError)")
//
//            case .keyNotFound(let codingKey, let decodingError):
//                print("keyNotFound: \(codingKey), \(decodingError)")
//
//            case .dataCorrupted(let decodingError):
//                print("dataCorrupted: \(decodingError)")
//
//            default:
//                print("unknown decoding error: \(error)")
//            }

            self = .decodingError(error)
        }  else {
            self = .unknownError(error)
        }
    }
    
}
