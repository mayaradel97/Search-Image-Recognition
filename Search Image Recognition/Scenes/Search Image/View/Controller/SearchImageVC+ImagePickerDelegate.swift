//
//  SearchImageVC+ImagePickerDelegate.swift
//  Search Image Recognition
//
//  Created by Mayar Adel .
//

import UIKit
extension SearchImageViewController :UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    func openCamera()  {
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            print("camera not found")
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        dismiss(animated: true, completion: nil)
        searchImageVM.uploadImageToFirebaseStorage()
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        {
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("error converting picked image to ciimage")
            }
            if  let imageData =  userPickedImage.jpegData(compressionQuality: 0.5)
            {
                searchImageVM.imageDataSubject.onNext(imageData) //to upload image to firebase storage
            }
            //classify picked image
            self.searchImageVM.detectImage(image:ciImage)
            
        }
        
        
        
    }
    
}

