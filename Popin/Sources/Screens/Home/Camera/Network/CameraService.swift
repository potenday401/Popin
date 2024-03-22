//
//  CameraService.swift
//  Popin
//
//  Created by Jihaha kim on 2024/03/20.
//

import UIKit
import Alamofire
import CoreLocation
import CoreData

final class CameraService: CameraServiceProtocol {
    let network: Network
    init(network: Network) {
        self.network = network
    }
    func uploadPin(selectedPhoto: UIImage?, capturedPhoto: UIImage?, initialLocation: CLLocation?, completion: @escaping (Result<String, Error>) -> Void) {
        let pinDTO = PinDTO(
            initialLocation: initialLocation,
            memberId: "1245",
            locality: "316",
            subLocality: "136171",
            photoDateTime: 0,
            photoPinId: "1246",
            tagIds: ["1234646"]
        )
        guard let initialLocation = pinDTO.initialLocation else {
          return
        }

        let uploadRequest = UploadRequest(
            initialLocation: initialLocation,
            memberID: pinDTO.memberId,
            locality: pinDTO.locality,
            subLocality: pinDTO.subLocality,
            photoDateTime: pinDTO.photoDateTime,
            photoPinId: pinDTO.photoPinId,
            tagIds: pinDTO.tagIds
        )
        network.send(uploadRequest) { result in
            switch result {
            case .success(let response):
                completion(.success(response.output.result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

protocol CameraServiceProtocol {
    func uploadPin(selectedPhoto: UIImage?, capturedPhoto: UIImage?, initialLocation: CLLocation?, completion: @escaping (Result<String, Error>) -> Void)
}
