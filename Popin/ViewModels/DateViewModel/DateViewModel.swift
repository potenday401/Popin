//
//  DateViewModel.swift
//  Popin
//
//  Created by 나리강 on 2/3/24.
//

import UIKit
import Alamofire

final class DateViewModel {
    
    let apiManager = APIManager.shared
    let imageCache = ImageCacheManager.shared
    
    //Data
    var imageUrlArray: [String]?
    var dateData: [DayOfMonthToItem]?
    var id: String?
    var year: Int {
        return changeDateToYear(date: Date())
    }
    var month: Int {
        return changeDateToMonth(date: Date())
    }
    
    //Output
    var mainImage: UIImageView?
    
    //Logic
    
    //- memberID: login 할 때 정보 저장해놔야함
    //- year: 보여지는 화면의 year
    //- month: 보여지는 화면의 month
    func fetchURLData(id: String, year: Int, month: Int) -> [String] {
        apiManager.fetchDateRecord(memberId: id, year: year, month: month) { [weak self] result in
            switch result {
            case .success(let data):
                print("success API networking")
                self?.dateData = data
                let urlString = self?.dateData?.map {  $0.photoURL }
               // self?.imageUrlArray = urlString
                
                self?.imageUrlArray = ["https://placekitten.com/100/100?image=1", "https://placekitten.com/100/100?image=2"]
                
//                if let imageURL = URL(string: urlString) {
//                    self?.changeURLtoImage(imageUrl: imageURL)
//                }
                
            case .failure(let error):
                print("fail to API networking")
                print(error.localizedDescription)
            }
        }
        return imageUrlArray ?? []
    }
    
    func updateDateImage(image: UIImageView) {
        let imageUrlString = imageUrlArray?.first ?? ""
        imageCache.loadImage(urlString: imageUrlString, image: image)
    }
    
    func goToAlbumView(currentVC: UIViewController, pushVC: AlbumViewController) {
        currentVC.navigationController?.pushViewController(pushVC, animated: true)
    }
    
    func changeDateToYear(date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        let convertDate = Int(dateFormatter.string(from: date))
        return convertDate ?? 2024
    }
    
    func changeDateToMonth(date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        let convertDate = Int(dateFormatter.string(from: date))
        return convertDate ?? 1
    }
    
    //비동기처리하는게 맞는지 고민해보기..
    //    private func changeURLtoImage(imageUrl: URL) {
    //        DispatchQueue.global().async { [weak self] in
    //            if let data = try? Data(contentsOf: imageUrl) {
    //                if let image = UIImage(data: data) {
    //                    DispatchQueue.main.async {
    //                        self?.mainImage?.image = image
    //                    }
    //                }
    //            }
    //        }
    //    }
    
}
