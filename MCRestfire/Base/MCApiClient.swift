//
//  MCApiClient.swift
//  MCRestfire
//
//  Created by Miller Mosquera on 30/08/23.
//

import Foundation
import Combine

// URLSession: The URLSession class is the key component of the URLSession stack. It's used to create and configure network requests.

// URLSessionConfiguration: A session configuration object is used to configure a URLSession instance.

// URLSessionTask: Is the workhorse of URLSession and its concrete subclasses:
// URLSessionDataTask: for fetching data ( directly inherit from URLSessionTask )
// URLSessionUploadTask: for uploading data ( is a subclass of URLSessionDataTask. )
// URLSessionDownloadTask: for downloading data ( directly inherit from URLSessionTask )

/**
 Sources:
 1) https://cocoacasts.com/networking-in-swift-meet-the-urlsession-family
 **/

// print in console: 'po varName'
// print in console: 'print varName'

public class MCApiClient: NSObject, MCApiClientProtocol {
        
    private var requestUrl: URL? = nil
    
    private(set) var configuration: MCRequestModel
    
    required public init(configuration: MCRequestModel) {
        self.configuration = configuration
        self.requestUrl = configuration.requestUrl
    }
    
    private func initRequest(baseURL: URL?) -> URLRequest? {
        
        guard let url = baseURL else {
            print("Error: Cannot create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = self.configuration.method.rawValue
        
        return request
    }
    
    private func setHttpRequestConfiguration(with config: MCRequestModel) -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = config.timeOut
        configuration.timeoutIntervalForResource = config.timeOut
        configuration.waitsForConnectivity = true
        configuration.httpAdditionalHeaders = config.headerData
        configuration.shouldUseExtendedBackgroundIdleMode = true
        configuration.allowsCellularAccess = true
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        return configuration
    }
    
    private func setHttpRequestBody(with body: Data?, request: inout URLRequest) {
        if let body {
            guard let bodyData = try? JSONEncoder().encode(body) else {
                print("Error: Trying to convert model to JSON data")
                return
            }
            request.httpBody = bodyData
        }
        
    }
    
    private func setDefaultHttpRequestHeader(request: inout URLRequest , headerValues: Array<[String: Any]>? = nil) {
        
        //var ddd = Array<[String: Any]>()
        //ddd.append(["x-mocks": "true"])
        //ddd.append(["x-lab-scope": "test3"])
        
        /*if let headerValues = headerValues {
            for value in headerValues {
                let key = value.keys
                
            }
        }*/
        

        // By default
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        /*if let headerValues = headerValues {
            for values in headerValues {
                
                request.addValue("x-mocks", forHTTPHeaderField: "")
                request.addValue("x-lab-scope", forHTTPHeaderField: "")
                request.addValue("x-user", forHTTPHeaderField: "")
            }
        }*/

    }
    
    private func castJsonObject(using data: Data) throws -> Any? {
        var finalObject: Any? = nil
        
        if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            finalObject = jsonObject
        } else if let  jsonObject = try JSONSerialization.jsonObject(with: data) as? [Any] {
            finalObject = jsonObject
        }
        
        return finalObject
    }
    
    private func processingData(data: Data) throws -> String {
        
        guard let jsonObject = try castJsonObject(using: data) else {
            throw MCNetworkError.decodingError
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        return jsonString ?? ""
    }
    
    private func parseDataFrom<T: Codable>(json jsonString: String, responseType: T.Type) -> T? {

        let data = jsonString.data(using: .utf8)!
        let dataConverted = try? JSONDecoder().decode(T.self, from: data)
        
        return dataConverted
        
    }
    
    // Request using combine
    private func getData<T: Codable>(for request: URLRequest) -> AnyPublisher<T, Error> {
        
        let session = URLSession(configuration: setHttpRequestConfiguration(with: self.configuration), delegate: self, delegateQueue: nil)
        
        return session.dataTaskPublisher(for: request)
            .map{ $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .subscribe(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    // Using just async/Await
    private func getData<T: Codable>(for request: URLRequest) async throws -> Result<T, MCNetworkError> {
        
        return try await withCheckedThrowingContinuation { continuation in
            let session = URLSession(configuration: setHttpRequestConfiguration(with: self.configuration), delegate: self, delegateQueue: nil)
            session.dataTask(with: request) { [self] data, response, error in
                do {
                    guard let data = data else {
                        throw MCNetworkError.decodingError
                    }
                    
                    let jsonStringData = try processingData(data: data)
                    let jsonData = parseDataFrom(json: jsonStringData, responseType: T.self)
                    
                    guard let jsonData = jsonData else {
                        throw MCNetworkError.decodingError
                    }
                    
                    continuation.resume(returning: .success(jsonData))
                } catch {
                    continuation.resume(returning: .failure(MCNetworkError.decodingError))
                }
            }.resume()
        }
        
    }
    
    private func getImageData(for request: URLRequest) -> AnyPublisher<Data, URLError> {
        
        let session = URLSession(configuration: setHttpRequestConfiguration(with: self.configuration), delegate: self, delegateQueue: nil)
        
        return session.dataTaskPublisher(for: request)
            .map{ $0.data }
            .subscribe(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
        
    public func send<T: Codable>() async throws -> AnyPublisher<T, Error> {
                
        guard var request = initRequest(baseURL: requestUrl) else { fatalError("Invalid URL") }
        
        setHttpRequestBody(with: self.configuration.body, request: &request)
        
        setDefaultHttpRequestHeader(request: &request)
    
        return getData(for: request)

    }
    
    public func send<T: Codable>() async -> Result<T, MCNetworkError> {
        guard var request = initRequest(baseURL: requestUrl) else { fatalError("Invalid URL") }
        
        setHttpRequestBody(with: self.configuration.body, request: &request)
        
        setDefaultHttpRequestHeader(request: &request)
    
        return try! await getData(for: request)
    }
    
    public func send() async throws -> AnyPublisher<Data, URLError> {
        guard var request = initRequest(baseURL: requestUrl) else { fatalError("Invalid URL") }
        
        setHttpRequestBody(with: self.configuration.body, request: &request)
        
        setDefaultHttpRequestHeader(request: &request)
    
        return getImageData(for: request)    }
    
}

extension MCApiClient: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)

        completionHandler(.useCredential, urlCredential)
    }
}
