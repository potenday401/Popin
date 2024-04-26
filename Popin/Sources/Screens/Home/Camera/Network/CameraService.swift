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
    
    func uploadPin(selectedPhoto: [UIImage], capturedPhoto: [UIImage], initialLocation: CLLocation?, accessToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        let dateString = "2024-04-26T05:33:33.784"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        if let date = dateFormatter.date(from: dateString) {
            if !selectedPhoto.isEmpty, let selectedImage = selectedPhoto.first {
                if let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
                    network.upload(
                        multipartFormData: { multipartFormData in
                            multipartFormData.append(imageData, withName: "image-file", fileName: "image.jpg", mimeType: "image/jpeg")
                        },
                        to: Endpoint.Pin.uploadPin.url,
                        method: .post,
                        headers: ["Authorization": "Bearer \(accessToken)", "Content-Type": "multipart/form-data"],
                        encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let response):
                                  print(response, "response!!!!!!!!")
//                                completion(.success(response))

//                                uploadRequest.responseDecodable { (response) in
//                                    // Handle response using completion handler
//                                }
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        })
                } else {
                    // Handle the case where image conversion fails
                }
            }

        } else {
            print("else")
        }
    }
}

protocol CameraServiceProtocol {
    func uploadPin(selectedPhoto: [UIImage], capturedPhoto: [UIImage], initialLocation: CLLocation?, accessToken: String, completion: @escaping (Result<String, Error>) -> Void)
}
