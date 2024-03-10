//
//  Endpoint.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//

import Foundation

struct Endpoint {
    
    static let baseURL = URL(string: "http://ec2-44-201-161-53.compute-1.amazonaws.com:8080/")!
    
    enum Auth {
        case login
        
        var url: URL {
            Endpoint.baseURL.appending(path: "auth/login")
        }
    }
    
    enum Member {
        case requestVerificationCode
        case requestVerification
        
        var url: URL {
            switch self {
            case .requestVerificationCode:
                Endpoint.baseURL.appending(path: "member/pre-signup")
            case .requestVerification:
                Endpoint.baseURL.appending(path: "member/email-verification")
            }
        }
    }
    
    enum Date {
        static let baseURL: String = "http://ec2-44-201-161-53.compute-1.amazonaws.com:8080/calendar-album?"
        static let memberId: String = "memberId="
        static let year: String = "&year="
        static let month: String = "&month="
    }
}
