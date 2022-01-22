//
//  FirebaseManager.swift
//  Search Image Recognition
//
//  Created by Mayar Adel
//

import Foundation
import FirebaseStorage

class FirebaseManager
{
    func uploadImageToFirebaseStorage(imageData:Data,completion:@escaping (String?)->())
    {
        let storageReference = Storage.storage().reference()
        let imageReference = storageReference.child("image.jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        imageReference.putData(imageData, metadata: metaData)
        { (metaData, error) in
            guard  error == nil
            else
            {
                completion(nil)
                return
                
            }
            imageReference.downloadURL
            { (imgURL, error) in
                guard  let imageURL = imgURL
                else
                {
                    completion(nil)
                    return
                }
                let url = imageURL.absoluteString
                completion(url)
                
            }
        }
        
    }
}
