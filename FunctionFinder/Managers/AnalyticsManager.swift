//
//  AnalyticsManager.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/6/23.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsManager {
    
    static let shared = AnalyticsManager()
    
    private init() {}
    
    func logEvent() {
        Analytics.logEvent("", parameters: [:])
    }
}
