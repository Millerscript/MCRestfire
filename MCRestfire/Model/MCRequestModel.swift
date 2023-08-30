//
//  MCRequestModel.swift
//  MCRestfire
//
//  Created by Miller Mosquera on 30/08/23.
//

import Foundation
public struct MCRequestModel {
    public var method: MCRequestMethod
    public var path: String
    public var timeOut: Double
    public var requestUrl: URL?
    public var headerData: [String: Any] = [:]
    public var body: Data?
    public var queryParams: [URLQueryItem] = []
    
    public init(method: MCRequestMethod,
                path: String? = "",
                timeOut: Double = 10,
                requestUrl: URL? = nil,
                headerData: [String: Any]? = [:],
                body: Data? = nil,
                queryParams: [URLQueryItem]? = []) {
        self.method = method
        self.path = path ?? ""
        self.timeOut = timeOut
        self.requestUrl = requestUrl
        self.headerData = headerData ?? [:]
        self.body = body
        self.queryParams = queryParams ?? []
    }
}
