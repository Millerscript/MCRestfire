//
//  MCNetworkError.swift
//  MCRestfire
//
//  Created by Miller Mosquera on 30/08/23.
//

import Foundation
public enum MCNetworkError: Error {
    case badURL
    case noData
    case decodingError
    case badServerResponse
}
