//
//  AppEnvironment.swift
//  MCRestfireExample
//
//  Created by Miller Mosquera on 30/08/23.
//

import Foundation
import MCRestfire

public enum ScopeError: Error {
    case invalidURL
}

open class AppEnvironment: MCEnvironmentProtocol {
    
    public var scope: MCScopes?
    
    public init(scope: MCScopes? = .Mock) {
        self.scope = scope
    }
    
    public func getUrl(endPoint: String) throws -> URL {
        
        switch scope {
            case .Develop:
                return URL(string: "https://languid-catkin-crayfish.glitch.me/\(endPoint)")!
            case .Test:
                return URL(string: "sometesturl\(endPoint)")!
            case .Mock:
                return URL(string: "somemockurl\(endPoint)")!
            case .Release:
                return URL(string: "somereleaseurl\(endPoint)")!
            case .Debug:
                return URL(string: "somedebug\(endPoint)")!
            case .Production:
                return URL(string: "someproduction\(endPoint)")!
            case .none:
                throw ScopeError.invalidURL
    
        }
    }
}
