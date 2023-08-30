//
//  LibVersion.swift
//  MCRestfireExample
//
//  Created by Miller Mosquera on 30/08/23.
//

import Foundation
struct LibVersion: Codable {
    let type: String
    let lib: String
    let author: String
    
    enum CodingKeys: CodingKey {
        case type
        case lib
        case author
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.lib = try container.decode(String.self, forKey: .lib)
        self.author = try container.decode(String.self, forKey: .author)
    }
    
    init(type: String, lib: String, author: String) {
        self.type = type
        self.lib = lib
        self.author = author
    }

}
