//
//  Network.swift
//  Popin
//
//  Created by chamsol kim on 3/3/24.
//

import Foundation

protocol Network {
    func send<T: Request>(_ request: T, completion: @escaping (Result<Response<T.Output>, Error>) -> Void)
}
