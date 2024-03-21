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
        let requestDTO = UploadRequestDTO(
            query: [:],
            initialLocation: initialLocation,
            selectedPhoto: selectedPhoto,
            capturedPhoto: capturedPhoto,
            memberId: "1245",
            locality: "316",
            subLocality: "136171",
            photoDateTime: 0,
            photoPinId: "1246",
            tagIds: ["1234646"]
        )
        
        network.send(requestDTO) { (result: Result<Response<UploadPinResponse>, Error>)  in
            switch result {
            case .success(let response):
                completion(.success(response.output.result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

private var sessionConfiguration: URLSessionConfiguration {
#if DEBUG
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [PopinURLProtocolMock.self]
    PopinTestSupport.setUpURLProtocol()
#else
    let configuration = URLSessionConfiguration.default
#endif
    return configuration
}

protocol CameraServiceProtocol {
    func uploadPin(selectedPhoto: UIImage?, capturedPhoto: UIImage?, initialLocation: CLLocation?, completion: @escaping (Result<String, Error>) -> Void)
}
