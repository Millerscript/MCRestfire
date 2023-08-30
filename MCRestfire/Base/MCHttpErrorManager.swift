//
//  MCHttpErrorManager.swift
//  MCRestfire
//
//  Created by Miller Mosquera on 30/08/23.
//

import Foundation
public class HttpErrorManager {
    
    public func requestError(urlDomain: String, error: Error?) -> NSError? {

        if let error {
            return NSError(domain: urlDomain, code: MCStatusCodes.INTERNAL_SERVER_ERROR.rawValue,
                                         userInfo: [NSLocalizedDescriptionKey:  "Error calling \(error)"])
        }
        
        if let error = error as? URLError {
            if error.code == .timedOut {
                print(error.errorCode)
                return NSError(domain: urlDomain, code: MCStatusCodes.TIMEOUT.rawValue,
                                             userInfo: [NSLocalizedDescriptionKey:  "request timeout"])
            }
        }
        
        return nil
    }
    
    public func requestResponseError(urlDomain: String, response: URLResponse?) -> NSError? {
        let successCodes = (200..<299)

        if let response = response as? HTTPURLResponse {
            
            if successCodes ~= response.statusCode {
                return nil
            }
            
            if response.statusCode == MCStatusCodes.TIMEOUT.rawValue {
                return NSError(domain: urlDomain, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:  "Error: Resquest timeout"])
            }
            
            return NSError(domain: urlDomain, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:  "Error: HTTP request failed"])
        }
        
        return nil
    }
    
}
