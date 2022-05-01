//
//  MockURLSession.swift
//  Falcon FlightsTests
//
//  Created by Harry Jordan on 01/05/2022.
//

import Foundation
import Combine

@testable import Falcon_Flights

class MockURLSession: URLSessionProtocol {
    var httpBody: Data?
    
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher {
        httpBody = request.httpBody
        return URLSession.DataTaskPublisher(request: request, session: URLSession.shared)
    }
    
}
