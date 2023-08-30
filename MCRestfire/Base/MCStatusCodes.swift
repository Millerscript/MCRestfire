//
//  MCStatusCodes.swift
//  MCRestfire
//
//  Created by Miller Mosquera on 30/08/23.
//

import Foundation
public enum MCStatusCodes: Int {
    case SUCESS = 200
    case CREATED = 201
    case NO_CONTENT = 204
    case BAD_REQUEST = 400
    case UNAUTHORIZED = 401
    case PAYMENT_REQUIRED = 402
    case FORBIDDEN = 403
    case NOT_FOUND = 404
    case TIMEOUT = 408
    case UNPROCESSABLE_ENTITY = 422
    case INTERNAL_SERVER_ERROR = 500
    case BAD_GATEWAY = 502
    case SERVICE_UNAVAILABLE = 503
}
