//
//  AppDelegate.swift
//  FunctionFinder
//
//  Created by Justin Wong on 5/23/23.
//

import Firebase
import UIKit
import GoogleMaps
import GooglePlaces
import Appirater

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Appirater.appLaunched(true)
//        Appirater.setAppId("3182731283")
        Appirater.setDebug(false)
        Appirater.setDaysUntilPrompt(3)
        
        GMSServices.provideAPIKey("AIzaSyBzl-jZ74yYVJH6-jeKpKnBgsYUoQnmzJc")
        GMSPlacesClient.provideAPIKey("AIzaSyBzl-jZ74yYVJH6-jeKpKnBgsYUoQnmzJc")
        
        FirebaseApp.configure()
        
        // Add dummy notification for current user
//        let id = NotificationsManager.newIdentifier()
//        let model = AppNotification(
//            identifier: id,
//            notificationType: 3,
//            profilePictureUrl: "https://iosacademy.io/assets/images/brand/icon.jpg",
//            username: "elonmusk",
//            dateString: String.date(from: Date()) ?? "Now",
//            isFollowing: false,
//            postId: nil,
//            postUrl: nil
//        )
//        NotificationsManager.shared.create(notification: model, for: "JustinWongaTonga")
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        Appirater.appEnteredForeground(true)
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

