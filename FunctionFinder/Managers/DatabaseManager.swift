//
//  DatabaseManager.swift
//  FunctionFinder
//
//  Created by Justin Wong on 5/26/23.
//

import Foundation
import FirebaseFirestore

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private init() {}
    
    private let database = Firestore.firestore()
    
    // MARK: - Public
    
    public func createUser(newUser: User, completion: @escaping (Bool) -> Void) {
        let reference = database.document("users/\(newUser.username)")
        guard let data = newUser.asDictionary() else {
            completion(false)
            return
        }
        reference.setData(data) { error in
            completion(error == nil)
        }
    }
}
