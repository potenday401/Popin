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
import Foundation

struct ImageDataa: Codable {
    let imageData: Data
}

final class CameraService: CameraServiceProtocol {
    let network: Network
    
    init(network: Network) {
        self.network = network
    }
    
    func uploadPin(selectedPhoto: [UIImage], capturedPhoto: [UIImage], initialLocation: CLLocation?, accessToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        let dateString = "2024-04-27T06:39:07.793"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        guard let date = dateFormatter.date(from: dateString) else {
            // Handle date parsing error
            return
        }
        if let imageData = selectedPhoto.first?.jpegData(compressionQuality: 0.1) {
            let imageDataStruct = ImageDataa(imageData: imageData)
            let jsonData = try? JSONEncoder().encode(imageDataStruct)
            print(String(data: jsonData ?? Data(), encoding: .utf8) ?? "")
        }

        guard let selectedImage = selectedPhoto.first,
              let imageData = selectedImage.jpegData(compressionQuality: 0.1) else {
            // Handle the case where image conversion fails
            return
        }
        
        let url = Endpoint.Pin.uploadPin.url
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let body = NSMutableData()
        
        // Content Id
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"contentId\"\r\n\r\n".utf8))
        body.append(Data("7\r\n".utf8))
        // Memorized At
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"memorizedAt\"\r\n\r\n".utf8))
        body.append(dateString.data(using: .utf8)!)
        body.append(Data("\r\n".utf8))
        
        // Image Data
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append("Content-Disposition: form-data; name=\"image-file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append(Data("\r\n".utf8))
        body.append(Data("--\(boundary)--\r\n".utf8))
        
        urlRequest.httpBody = body as Data
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                // Handle invalid response
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                // Handle non-200 status code
                return
            }
            
            if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
                completion(.success(responseString))
            } else {
                // Handle invalid response data
            }
        }
        task.resume()
    }
}



protocol CameraServiceProtocol {
    func uploadPin(selectedPhoto: [UIImage], capturedPhoto: [UIImage], initialLocation: CLLocation?, accessToken: String, completion: @escaping (Result<String, Error>) -> Void)
}
