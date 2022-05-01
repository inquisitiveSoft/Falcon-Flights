//
//  LaunchRelatedDataTypes.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 01/05/2022.
//

import Foundation


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
        case flightNumber = "flight_number"
        case name
        case date = "date_utc"
        case success
        case imageURLs
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
        case original
    }
    
    var id: String
    var flightNumber: Int
    var name: String
    var date: Date
    var success: Bool
    var imageURLs: [URL]
    var patchImageURL: URL?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(String.self, forKey: .id)
        flightNumber = try values.decode(Int.self, forKey: .flightNumber)
        name = try values.decode(String.self, forKey: .name)
        date = try values.decode(Date.self, forKey: .date)
        success = try values.decode(Bool.self, forKey: .success)
        
        // Unpack nested structures to get the image urls
        let links = try values.nestedContainer(keyedBy: LinksKeys.self, forKey: .links)
        let flickrImages = try links.nestedContainer(keyedBy: FlickrDictionaryKeys.self, forKey: .flickr)
        imageURLs = (try? flickrImages.decode([URL].self, forKey: .original)) ?? []
        
        let patchImage = try links.nestedContainer(keyedBy: PatchKeys.self, forKey: .patch)
        patchImageURL = try? patchImage.decode(URL.self, forKey: .large)
    }
}
