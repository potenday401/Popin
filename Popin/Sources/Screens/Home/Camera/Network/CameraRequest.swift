//
//  CameraRequest.swift
//  Popin
//
//  Created by Jihaha kim on 2024/03/21.
//

import CoreLocation
import UIKit

struct UploadRequest: Request {
  typealias Query = PinDTO
  typealias Output = UploadPinResponse

  var endpoint: URL = Endpoint.Pin.uploadPin.url
  var method: HTTPMethod = .post
  var header: HTTPHeader = [:]

  var query: Query?

  init(query: Query?) {
    self.query = query
  }

  var urlRequest: URLRequest {
    var urlRequest = URLRequest(url: endpoint)
    urlRequest.httpMethod = method.rawValue

    if let accessToken = query?.accessToken {
      urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    }

    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

    if let queryData = try? JSONEncoder().encode(query) {
      urlRequest.httpBody = queryData
    }

    return urlRequest
  }
}


struct UploadPinResponse: Decodable {
    let result: String
}

struct PinDTO: Encodable {
  let contentId: Int64
  let memorizedAt: Date
  let imageFile: String
  var accessToken: String
    
  enum CodingKeys: String, CodingKey {
    case contentId
    case memorizedAt
    case imageFile
    case accessToken
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(contentId, forKey: .contentId)

    let formatter = ISO8601DateFormatter()
    let dateString = formatter.string(from: memorizedAt)
    try container.encode(dateString, forKey: .memorizedAt)

    try container.encode(imageFile, forKey: .imageFile)
    try container.encode(accessToken, forKey: .accessToken)
  }
}
