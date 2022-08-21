//
//  StrorageManger.swift
//  ChatNow
//
//  Created by uttam on 30/07/22.
//

import Foundation
import FirebaseStorage



final class StrorageManger{
    // Get a reference to the storage service using the default Firebase App
    static let shared = StrorageManger()

    // Create a storage reference from our storage service
     let storageRef = Storage.storage().reference()
//    let data = Data()
    
    public typealias UploadPictureConpletion=(Result<String,Error>)->Void
    
    public func uploadrofilePicture(with data:Data,filename:String,completion:@escaping UploadPictureConpletion){
        storageRef.child("images/\(filename)").putData(data, metadata: nil) {[weak self] metaData, error in
            guard error==nil else{
                print("faild to upload image URL")
                completion(.failure(StorageError.failedToUpload))
                return
            }
            self?.storageRef.child("images/\(filename)").downloadURL { url, error in
                guard let url=url else{
                    print("failed to dowload url")
                    completion(.failure(StorageError.failedToDownloadURL))
                    return
                }
                let urlString=url.absoluteString
                print("download url resturn: \(urlString)")
                completion(.success(urlString))
                
            }
        }
    }
    
    public enum StorageError:Error{
        case failedToUpload
        case failedToDownloadURL
    }
    public typealias DownloadPictureCompletion=(Result<URL,Error>)->Void

    
    public func downloadURL(for path:String,completion:@escaping DownloadPictureCompletion){
        storageRef.child(path).downloadURL { url, error in
            guard let url=url, error==nil else{
                completion(.failure(StorageError.failedToDownloadURL))
                return
            }
            completion(.success(url))
            
        }
    }

    
}
    
