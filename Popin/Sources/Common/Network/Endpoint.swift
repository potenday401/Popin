//
//  Endpoint.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//

import Foundation

struct Endpoint { }
extension Endpoint {
    enum Pin {
        static let baseURL: String = "https://..."
    }
}

extension Endpoint {
    enum Date {
        static let baseURL: String = "http://ec2-44-201-161-53.compute-1.amazonaws.com:8080/calendar-album?"
        static let memberId: String = "memberId="
        static let year: String = "&year="
        static let month: String = "&month="
    }
}
