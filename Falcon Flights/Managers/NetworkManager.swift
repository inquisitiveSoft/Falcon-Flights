//
//  FlightNetworkManager.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 29/04/2022.
//

import Foundation
import Combine


/// Creating a protocol to allow a mock object to be inserted instead of URLSession for testing
protocol URLSessionProtocol {
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher
}

extension URLSession: URLSessionProtocol {}

// MARK: Data Types
enum RocketType: String {
    case falcon9 = "5e9d0d95eda69973a809d1ec"
    
    var name: String {
        switch self {
        case .falcon9:
            return "Falcon 9"
        }
    }
    
    var uuidString: String {
        return rawValue
    }
}

enum Query {
    case rocket(RocketType, pageNumber: Int?)
    
    func url(withAPIRoot apiRoot: URL) -> URL {
        switch self {
        case .rocket(_, _):
            return apiRoot.appendingPathComponent("launches/query")
        }
    }
    
    var httpMethod: String {
        switch self {
        case .rocket:
            return "POST"
        }
    }
        
}

struct RocketItem: Decodable, Identifiable {
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case date = "date_utc"
        case imageURL
        case links
    }
    
    private enum LinksKeys: String, CodingKey {
        // Only including the keys that we're interested in
        // Ref: https://github.com/r-spacex/SpaceX-API/blob/master/docs/launches/v5/query.md
        case patch
        case flickr
    }
    
    private enum PatchKeys: String, CodingKey {
        case large
    }
    
    private enum FlickrDictionaryKeys: String, CodingKey {
        case large
    }
    
    var id: String
    var name: String
    var date: Date
    var imageURLs: [URL]
    var patchImageURL: URL?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        date = try values.decode(Date.self, forKey: .date)
        
        // Unpack nested structures to get the image urls
        let links = try values.nestedContainer(keyedBy: LinksKeys.self, forKey: .links)
        let mainImage = try links.nestedContainer(keyedBy: FlickrDictionaryKeys.self, forKey: .flickr)
        imageURLs = (try? mainImage.decode([URL].self, forKey: .large)) ?? []
        
        let patchImage = try links.nestedContainer(keyedBy: PatchKeys.self, forKey: .patch)
        patchImageURL = try? patchImage.decode(URL.self, forKey: .large)
    }
}

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

// MARK: Data types involved with networking

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
        
        // In theory the api returns iso8601 dates
        // but it doesn't seem to decode
        // so using a custom date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        dateFormatter.locale
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return decoder
    }()

    init(urlSession: URLSessionProtocol = URLSession(configuration: .default)) {
        self.urlSession = urlSession
    }
    
    // Item.type parameter here is unfortunately necessary to specialise the generic function
    func fetchQuery<Item: Decodable>(_ query: Query, itemType: Item.Type) -> AnyPublisher<(Query, Item), APIError> {
        // Create the request
        let url = query.url(withAPIRoot: apiRootURL)
        var request =  URLRequest(url: url)
        request.httpMethod = query.httpMethod
        
        if let requestBody = RequestBody(query: query) {
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

/// Extension that helps 
extension NetworkManager.APIError {
    
    init(error: Error) {
        // Mapping errors like this helps work around Combine types
        if let error = error as? DecodingError {
            switch error {
            case .typeMismatch(let any, let decodingError):
                print("typeMismatch: \(any), \(decodingError)")
                
            case .valueNotFound(let any, let decodingError):
                print("valueNotFound: \(any), \(decodingError)")
                
            case .keyNotFound(let codingKey, let decodingError):
                print("keyNotFound: \(codingKey), \(decodingError)")
                
            case .dataCorrupted(let decodingError):
                print("dataCorrupted: \(decodingError)")
                
            default:
                print("unknown decoding error: \(error)")
            }
            
            self = .decodingError(error)
        }  else {
            print("url error: \(error)")
            self = .unknownError(error)
        }
    }
    
}
