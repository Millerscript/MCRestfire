//
//  MCRestClient.swift
//  MCRestfire
//
//  Created by Miller Mosquera on 30/08/23.
//

import Foundation
import Combine

open class MCRestClient {
    
    private var environment: MCEnvironmentProtocol
    
    // default init
    public init(environment: MCEnvironmentProtocol) {
        self.environment = environment
    }
    
    // TODO: Configuration should be part of APIClient class
    private func setup(request: MCRequestModel) -> MCApiClient {
        var requestUrl: URL?

        if let url = request.requestUrl {
            requestUrl = url
        } else {
            requestUrl = try? environment.getUrl(endPoint: request.path)
        }

        var configuration = request
        configuration.requestUrl = requestUrl
        configuration.timeOut = request.timeOut
        
        return MCApiClient(configuration: configuration)
    }
    
    // Testing
    public func executeWith<T: Codable>(request: MCRequestModel) async -> AnyPublisher<T, Error> {
            return try! await setup(request: request).send()
    }
    
    public func executeWith(request: MCRequestModel) async -> AnyPublisher<Data, URLError> {
            return try! await setup(request: request).send()
    }
    
    public func executeWith<T: Codable>(request: MCRequestModel) async -> Result<T, MCNetworkError> {
        return await setup(request: request).send()
    }
}
