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
        guard let initialLocation = initialLocation else {
            return
        }
        let location = CLLocation(latitude: initialLocation.coordinate.latitude, longitude: initialLocation.coordinate.longitude)
        let pinDTO = PinDTO(initialLocation: location, memberId: "1245", locality: "316", subLocality: "136171", photoDateTime: 0, photoPinId: "1246", tagIds: ["1234646"])
        let uploadRequest = UploadRequest(query: pinDTO)
        
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
