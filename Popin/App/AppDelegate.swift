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
        appRouter = AppRouterImp(dependency: .init(network: network, tokenRepository: tokenRepository))
        appRouter?.window = window
        appRouter?.launch()
        
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

