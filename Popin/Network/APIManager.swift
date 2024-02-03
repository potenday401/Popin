//
//  NetworkManager.swift
//  Popin
//
//  Created by 나리강 on 2/3/24.
//

import Foundation
import Alamofire

final class APIManager {
    static let shared = APIManager()
    private init () { }
    
    //해당 날짜의 모든 데이터 가져옴
    func fetchDateRecord(memberId: String,year: Int,month: Int,completion: @escaping (Result<[DayOfMonthToItem], Error>) -> Void) {
        
        let parameters: Parameters = [
                    "memberId": memberId,
                    "year" : year,
                    "month": month
                ]
        let urlString = Endpoint.Date.baseURL
        guard let url = URL(string: urlString) else { return }
        
        AF.request(url, method: .get, parameters: parameters).responseData { response in
            
            switch response.result {
            case .success(let data):
                print("success")
                guard let result = self.parseJSON(data) else {
                    print("fail to parsing")
                    return }
                
                completion(.success(result))
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //Data -> 원하는 형태의 구조체로 변경 (parsing)
    private func parseJSON(_ data: Data) -> [DayOfMonthToItem]? {
        do {
            let data = try JSONDecoder().decode(DateRecord.self, from: data)
            return data.dayOfMonthToItem
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
