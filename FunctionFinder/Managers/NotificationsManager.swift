//
//  NotificationsManager.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/12/23.
//

import Foundation

final class NotificationsManager {
    static let shared = NotificationsManager()
    
    enum AppType: Int {
        case like = 1
        case comment = 2
        case follow = 3
    }
    
    private init() {}
    
    public func getNotifications(completion: @escaping ([AppNotification]) -> Void) {
        DatabaseManager.shared.getNotifications(completion: completion)
    }
    
    static func newIdentifier() -> String {
        let date = Date()
        let number1 = Int.random(in: 0...1000)
        let number2 = Int.random(in: 0...1000)
        return "\(number1)_\(number2)_\(date.timeIntervalSince1970)"
    }
    
    public func create(notification: AppNotification, for username: String) {
        let identifier = notification.identifier
        guard let dictionary = notification.asDictionary()
        else {
            return
        }
        DatabaseManager.shared.insertNotification(
            identifier: identifier,
            data: dictionary,
            for: username
        )
    }
}
