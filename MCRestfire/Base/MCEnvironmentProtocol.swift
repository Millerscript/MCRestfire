//
//  MCEnvironmentProtocol.swift
//  MCRestfire
//
//  Created by Miller Mosquera on 30/08/23.
//

import Foundation
public protocol MCEnvironmentProtocol {
    var scope: MCScopes? {get set}
    func getUrl(endPoint: String) throws -> URL
}
