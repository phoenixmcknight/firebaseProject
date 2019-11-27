//
//  FirebaseStorageService.swift
//  firebae-reddit-clone
//
//  Created by David Rifkin on 11/13/19.
//  Copyright © 2019 David Rifkin. All rights reserved.
//

import Foundation
import FirebaseStorage

enum imageFolders:String {
    case profileImages
    case tempImages
    case postImages
}
class FirebaseStorageService {
    static var manager = FirebaseStorageService()
    
    private let storage: Storage!
    private let storageReference: StorageReference
    private let profileImageFolderReference: StorageReference
    private let tempImageFolderReference:StorageReference
    private let postImageFolderReference:StorageReference
    
    private init() {
        storage = Storage.storage()
        storageReference = storage.reference()
        profileImageFolderReference = storageReference.child(imageFolders.profileImages.rawValue)
        postImageFolderReference = storageReference.child(imageFolders.postImages.rawValue)
        tempImageFolderReference = storageReference.child(imageFolders.tempImages.rawValue)
        
      
        
    }
    
    func storeImage(image: Data, destination:imageFolders,  completion: @escaping (Result<URL,Error>) -> ()) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
       let uuid = UUID()
        var imageLocation:StorageReference!
        switch destination {
        case .profileImages:
            imageLocation =  profileImageFolderReference.child(uuid.description)
            
        case .tempImages:
            imageLocation =  tempImageFolderReference.child(uuid.description)
             
        case .postImages:
            imageLocation =  postImageFolderReference.child(uuid.description)

        }
//        let imageLocation = imagesFolderReference.child(uuid.description)
        imageLocation.putData(image, metadata: metadata) { (responseMetadata, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                //Try to get the actual URL for our image
                imageLocation.downloadURL { (url, error) in
                    guard error == nil else {completion(.failure(error!));return}
                    //MARK: TODO - set up custom app errors
                    guard let url = url else {completion(.failure(error!));return}
                    completion(.success(url))
                }
            }
        }
    }
}
