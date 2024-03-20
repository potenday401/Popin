//
//  CameraService.swift
//  Popin
//
//  Created by Jihaha kim on 2024/03/20.
//

import UIKit
import Alamofire
import CoreLocation

class CameraService {
    static let shared = CameraService()
    private let baseUrl = "http://ec2-44-201-161-53.compute-1.amazonaws.com:8080/"
    
        func sendAction(selectedPhoto: UIImage?, capturedPhoto: UIImage?, initialLocation: CLLocation?, baseUrl: String) {
            guard let base64String = selectedPhoto?.toBase64() ?? capturedPhoto?.toBase64() else {
                print("Image is nil.")
                return
            }
            let parameters: Parameters = [
                "latLng": [
                    "latitude": initialLocation?.coordinate.latitude,
                    "longitude": initialLocation?.coordinate.longitude
                ],
                "memberId": "1245",
                "locality": "316",
                "subLocality": "136171",
                "photoDateTime": 0,
                "photoFileBase64Payload": base64String,
                "photoFileExt": "jpg",
                "photoPinId": "1246",
                "tagIds": [
                    "1234646"
                ]
            ]
            AF.session.configuration.timeoutIntervalForRequest = 60
            AF.request(baseUrl + "photo-pins", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json", "Accept":"application/json"]).responseData() { response in
                debugPrint(response)
                
                switch response.result {
                case .success:
                    if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                        print("Response Data: \(jsonString)")
                    }
                    
                    if let jsonObject = try? response.result.get() as? [String: Any] {
                        print("Object: \(jsonObject)")
                        let result = jsonObject["result"] as? String
                        print("요청결과: \(result!)")
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }

}

