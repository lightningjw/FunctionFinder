//
//  FunctionFinderTests.swift
//  FunctionFinderTests
//
//  Created by Justin Wong on 5/23/23.
//

import XCTest
@testable import FunctionFinder

final class FunctionFinderTests: XCTestCase {
    
    func testNotificationIDCreation() {
        let first = NotificationsManager.newIdentifier()
        let second = NotificationsManager.newIdentifier()
        XCTAssertNotEqual(first, second)
    }
    
    
}
