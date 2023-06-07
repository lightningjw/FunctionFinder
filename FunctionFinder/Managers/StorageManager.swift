//
//  StorageManager.swift
//  FunctionFinder
//
//  Created by Justin Wong on 5/26/23.
//

import Foundation
import FirebaseStorage

public class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    private let storage = Storage.storage().reference()
    
    public enum StorageManagerError: Error {
        case failedToDownload
    }
    
    // MARK: - Public
    
    public func uploadProfilePicture(username: String, data: Data?, completion: @escaping (Bool) -> Void) {
        guard let data = data else {
            return
        }
        storage.child("\(username)/profile_picture.png").putData(data, metadata: nil) { _, error in
            completion(error == nil)
        }
    }
    
    public func uploadUserPhotoPost(model: UserPost, completion: @escaping (Result<URL, Error>) -> Void) {
        
    }
    
    public func downloadImage(with reference: String, completion: @escaping (Result<URL, StorageManagerError>) -> Void) {
        storage.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(.failedToDownload))
                return
            }
            
            completion(.success(url))
        })
    }

}
