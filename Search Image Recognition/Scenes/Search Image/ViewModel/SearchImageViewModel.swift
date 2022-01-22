//
//  SearchImageViewModel.swift
//  Search Image Recognition
//
//  Created by Mayar Adel on 12/26/21.
//

import Foundation
import CoreML
import Vision
import RxSwift
import RxCocoa
class SearchImageViewModel
{
    private var firebaseManager:FirebaseManager!
    var accurateImageClassificationBehavior = BehaviorRelay<String>(value: "Take a picture")
    var loadingIndicatorBehavior = BehaviorRelay<Bool>(value: true)
    var searchIconBehavior = BehaviorRelay<Bool>(value: false)
    var webViewBehavior = BehaviorRelay<Bool>(value: true)
    var imageDataSubject = PublishSubject<Data>()
    var googleURLSubject = PublishSubject<URL>()
    var errorMessageSubject = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    func manageHiddenUI()
    {
        loadingIndicatorBehavior.accept(false)//start loading
        searchIconBehavior.accept(true)//hide search icon
        webViewBehavior.accept(false)
    }
    func uploadImageToFirebaseStorage()
    {
        self.manageHiddenUI()
        firebaseManager = FirebaseManager()
        imageDataSubject.asObserver().subscribe
        { [weak self](imgData) in
            guard let self = self else {return}
            guard let imageData = imgData.element else {return}
            self.firebaseManager.uploadImageToFirebaseStorage(imageData: imageData)
            { (imageURL) in
                guard let imageURL = imageURL
                else
                {
                    self.errorMessageSubject.onNext("An error occurred when loading image url")
                    return
                }
                //google method
                self.displayGoogleSearchInWebView(andURL: imageURL)
            }
        }.disposed(by: disposeBag)
        
    }
    func detectImage(image:CIImage)
    {
        //vncoremlmodel is a container of our model and it comes from vision
        guard let model = try? VNCoreMLModel(for:Resnet50(configuration: .init()).model )
        else
        {
            errorMessageSubject.onNext("loading coreml model failed")
            return
        }
        //vision coreml request
        let request = VNCoreMLRequest(model: model)
        { [weak self](request, error) in
            guard let self = self else {return}
            guard let classificationFirstResult = request.results?.first as? VNClassificationObservation else
            {
                self.errorMessageSubject.onNext("model failed to process image")
                return
            }
            let accurateValueOfImageClassification = classificationFirstResult.identifier
            self.accurateImageClassificationBehavior.accept(accurateValueOfImageClassification)
        }
        //specify the image we want to classify it
        let handler = VNImageRequestHandler(ciImage:image )
        do
        {
            try  handler.perform([request])
        }
        catch
        {
            self.errorMessageSubject.onNext("model failed to process image")
            return
        }
    }
    func displayGoogleSearchInWebView(andURL imageURL:String)
    {
        accurateImageClassificationBehavior.subscribe
        { [weak self] (imageClassificationValue) in
            guard let self = self else {return}
            let imageText = imageClassificationValue.element!.encodedURL()
            guard let url = URL(string: "https://www.google.com/searchbyimage?q=\(imageText)&site=search&sa=X&image_url=\(imageURL)")
            else
            {
                return
            }
            self.googleURLSubject.onNext(url)
        }.disposed(by: disposeBag)
    }
    
}
