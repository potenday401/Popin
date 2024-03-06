//
//  Response.swift
//  Popin
//
//  Created by chamsol kim on 3/3/24.
//

import Foundation

struct Response<Output: Decodable> {
    let output: Output
    let statusCode: Int
}
