//
//  MCApiClientProtocol.swift
//  MCRestfire
//
//  Created by Miller Mosquera on 30/08/23.
//

import Foundation
import Combine

public protocol MCApiClientProtocol: AnyObject {
    func send<T: Codable>() async throws -> AnyPublisher<T, Error>
    func send<T: Codable>() async throws -> Result<T, MCNetworkError>
}
