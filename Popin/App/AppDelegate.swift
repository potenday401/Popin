//
//  AppDelegate.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appRouter: AppRouter?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        let network = AlamofireNetwork(configuration: sessionConfiguration)
        let tokenStorage = TokenKeychainStorage()
        let tokenRepository = TokenRepositoryImp(storage: tokenStorage)
        let validator = EmailPasswordValidator()
        appRouter = AppRouterImp(dependency: .init(network: network, tokenRepository: tokenRepository, validator: validator))
        appRouter?.window = window
        appRouter?.launch()
        return true
    }
    
//    func applicationWillTerminate(_ application: UIApplication) {
//        TokenManager.shared.clearTokens()
//    }
    
    private func refreshAccessToken(refreshToken: String) {
        // 리프레시 토큰을 사용하여 새로운 액세스 토큰 발급
        // 성공 시 routeToHome(accessToken: newAccessToken)
        // 실패 시 routeToLogin()
    }
    
    private func isValidToken(_ token: String) -> Bool {
        // 토큰 유효성 검사 로직
        return true
    }
    
    private var sessionConfiguration: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        return configuration
    }
}
