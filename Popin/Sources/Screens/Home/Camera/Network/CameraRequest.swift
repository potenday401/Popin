//
//  CameraRequest.swift
//  Popin
//
//  Created by Jihaha kim on 2024/03/21.
//

import CoreLocation
import UIKit

struct UploadRequest: Request {
    var query: PinDTO?
    
    typealias Query = PinDTO
    typealias Output = UploadPinResponse
    var endpoint: URL = Endpoint.Pin.uploadPin.url
    var method: HTTPMethod = .post
    var header: HTTPHeader = [:]
    init(initialLocation: CLLocation, memberID: String, locality: String, subLocality: String, photoDateTime: Int, photoPinId: String, tagIds: [String]) {
      let pinDTO = PinDTO(
        initialLocation: initialLocation,
        memberId: memberID,
        locality: locality,
        subLocality: subLocality,
        photoDateTime: photoDateTime,
        photoPinId: photoPinId,
        tagIds: tagIds
      )
      query = pinDTO
    }
}

struct UploadPinResponse: Decodable {
    let result: String
}

struct PinDTO: Encodable {
    var initialLocation: CLLocation?
    var selectedPhoto: UIImage?
    var capturedPhoto: UIImage?
    var memberId: String
    var locality: String
    var subLocality: String
    var photoDateTime: Int
    var photoPinId: String
    var tagIds: [String]
    
    enum CodingKeys: String, CodingKey {
        case initialLocation
        case selectedPhoto
        case capturedPhoto
        case memberId
        case locality
        case subLocality
        case photoDateTime
        case photoPinId
        case tagIds
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let initialLocation = initialLocation {
            let locationString = "\(initialLocation.coordinate.latitude),\(initialLocation.coordinate.longitude)"
            try container.encode(locationString, forKey: .initialLocation)
        }
        
        if let selectedPhoto = selectedPhoto, let imageData = selectedPhoto.jpegData(compressionQuality: 0.8) {
            let base64String = imageData.base64EncodedString()
            try container.encode(base64String, forKey: .selectedPhoto)
        }
        
        if let capturedPhoto = capturedPhoto, let imageData = capturedPhoto.jpegData(compressionQuality: 0.8) {
            let base64String = imageData.base64EncodedString()
            try container.encode(base64String, forKey: .capturedPhoto)
        }
        
        try container.encode(memberId, forKey: .memberId)
        try container.encode(locality, forKey: .locality)
        try container.encode(subLocality, forKey: .subLocality)
        try container.encode(photoDateTime, forKey: .photoDateTime)
        try container.encode(photoPinId, forKey: .photoPinId)
        try container.encode(tagIds, forKey: .tagIds)
    }
}
