//
//  AuthManager.swift
//  FunctionFinder
//
//  Created by Justin Wong on 5/26/23.
//

import FirebaseAuth
import Foundation

final class AuthManager {
    
    static let shared = AuthManager()
    
    private init() {}
    
    let auth = Auth.auth()
    
    enum AuthError: Error {
        case newUserCreation
    }
    
    public var isLoggedIn: Bool {
        return auth.currentUser != nil
    }
    
//    public func loginUser(username: String?, email: String?, password: String, completion: @escaping (Result<User,Error>) -> Void){
//        if let email = email {
//            // phone log in
//            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
//                guard authResult != nil, error == nil else {
//                    completion(false)
//                    return
//                }
//                
//                completion(true)
//            }
//        }
//        else if let username = username {
//            // username log in
//            print(username)
//        }
//    }
//    
    public func registerNewUser(username: String, email: String, password: String, profilePicture: Data?, completion: @escaping (Result<User,Error>) -> Void){
        let newUser = User(username: username, email: email)
        auth.createUser(withEmail: email, password: password) { result, error in
            guard result != nil, error == nil else {
                // Firebase auth could not create account
                completion(.failure(AuthError.newUserCreation))
                return
            }
            
            // Insert into database
            DatabaseManager.shared.createUser(newUser: newUser) { success in
                if success {
                    StorageManager.shared.uploadProfilePicture(
                        username: username,
                        data: profilePicture
                    ) { uploadSuccess in
                        if uploadSuccess {
                            completion(.success(newUser))
                        }
                        else {
                            completion(.failure(AuthError.newUserCreation))
                        }
                    }
                }
                else {
                    completion(.failure(AuthError.newUserCreation))
                }
            }
    }
}
    
    /// Attempt to log out firebase user
    public func logOut(completion: (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
            return
        }
        catch{
            completion(false)
            print(error)
            return
        }
    }
    
}
