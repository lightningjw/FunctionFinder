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
        case loginFailed
    }
    
    public var isLoggedIn: Bool {
        return auth.currentUser != nil
    }
    
    public func loginUser(email: String, password: String, completion: @escaping (Result<User,Error>) -> Void){
        DatabaseManager.shared.findUser(with: email) { [weak self] user in
            guard let user = user else {
                completion(.failure(AuthError.loginFailed))
                return
            }
            
            self?.auth.signIn(withEmail: email, password: password) { result, error in
                guard result != nil, error == nil else {
                    completion(.failure(AuthError.loginFailed))
                    return
                }
                
                UserDefaults.standard.setValue(user.username, forKey: "username")
                UserDefaults.standard.setValue(user.email, forKey: "email")
                completion(.success(user))
            }
        }
    }
    
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
    
    public func logOut(completion: @escaping (Bool) -> Void) {
        do {
            try auth.signOut()
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
