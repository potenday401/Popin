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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        let network = AlamofireNetwork(configuration: sessionConfiguration)
        let tokenStorage = TokenKeychainStorage()
        let tokenRepository = TokenRepositoryImp(storage: tokenStorage)
        window?.rootViewController = LoginViewController(
            dependency: .init(
                loginService: LoginServiceImp(network: network),
                tokenRepository: tokenRepository
            )
        )
        
        return true
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
}

