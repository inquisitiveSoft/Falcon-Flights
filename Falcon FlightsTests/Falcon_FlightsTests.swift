//
//  Falcon_FlightsTests.swift
//  Falcon FlightsTests
//
//  Created by Harry Jordan on 28/04/2022.
//

import XCTest
import Combine
@testable import Falcon_Flights

class Falcon_FlightsTests: XCTestCase {
    var cancellable = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        cancellable.removeAll()
    }

    func testRequestBodyForInitialPage() throws {
        try performFetchQueryTest(.rocket(.falcon9, pageNumber: nil),
                                  expectation: """
        {
          "options": {
              "sort": {
                  "flight_number": "ascending"
              }
          },
          "query": {
              "upcoming": false,
              "rocket": "5e9d0d95eda69973a809d1ec"
          }
        }
        """)
    }
    
    func testRequestBodyForSubsequentPage() throws {
        try performFetchQueryTest(.rocket(.falcon9, pageNumber: 3),
                                  expectation: """
        {
          "options": {
              "sort": {
                  "flight_number": "ascending"
              },
              "page": 3
          },
          "query": {
              "upcoming": false,
              "rocket": "5e9d0d95eda69973a809d1ec"
          }
        }
        """)
    }
    
    func performFetchQueryTest(_ query: Query, expectation expectedJSON: String) throws {
        let expectation = self.expectation(description: "Query")
        let urlSession = MockURLSession()
        
        let networkManager = NetworkManager(urlSession: urlSession)
        let flightManager = FlightManager(networkManager: networkManager)
        
        flightManager.networkManager.fetchQuery(query,
                                                sortOptions: ["flight_number": .ascending],
                                                itemType: ResponsePage<RocketItem>.self)
            .sink { completionHandler in
                expectation.fulfill()
            } receiveValue: { (query, _) in
                // Not actually expecting a result
            }
            .store(in: &cancellable)
        
        waitForExpectations(timeout: 5, handler: nil)
        
        guard let httpBody = urlSession.httpBody else {
            return XCTFail("No http body")
        }

        guard let requestJSON = try JSONSerialization.jsonObject(with: httpBody) as? [String: Any] else {
            return XCTFail("Couldn't unwrap response json object")
        }
        
        guard let expectatedJSONData = expectedJSON.data(using: .utf8),
              let expectedJSON = try JSONSerialization.jsonObject(with: expectatedJSONData) as? [String: Any] else {
            return XCTFail("Couldn't unwrap expectation json object")
        }
        
        // Comparing for JSON equality without worrying about field order etc.
        // by converting to NSDictionary
        XCTAssertEqual(NSDictionary(dictionary: requestJSON), NSDictionary(dictionary: expectedJSON))
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
