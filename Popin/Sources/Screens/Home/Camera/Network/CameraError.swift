//
//  CameraError.swift
//  Popin
//
//  Created by Jihaha kim on 2024/03/21.
//
import Foundation

enum CameraError: LocalizedError {
    case noData
    case failUpload
    
    var errorDescription: String? {
        switch self {
        case .noData:
            "데이터가 없습니다"
        case .failUpload:
            "업로드에 실패하였습니다"
        }
    }
}
