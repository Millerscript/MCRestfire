//
//  ExampleRepository.swift
//  MCRestfireExample
//
//  Created by Miller Mosquera on 30/08/23.
//

import Foundation
import Combine
import MCRestfire

class ExampleRepository {
    
    private let restClient = MCRestClient(environment: AppEnvironment(scope: .Develop))
    
    init() {}
    
    // Glitch server
    /*func testingSomething() async -> AnyPublisher<LibVersion, Error> {
        let request = RequestModel(method: .GET, path:  "author")
        return await restClient.executeWith(request: request)
    }*/
    
    func testingSomething() async -> Result<LibVersion, MCNetworkError> {
        let request = MCRequestModel(method: .GET, path:  "author")
        return await restClient.executeWith(request: request)
    }
    
    func test() async -> Result<[Interest], MCNetworkError> {
        let request = MCRequestModel(method: .GET, path: "user_interests")
        return await restClient.executeWith(request: request)
    }
    
}
