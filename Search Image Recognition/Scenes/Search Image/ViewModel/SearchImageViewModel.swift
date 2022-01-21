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
    var googleURL = PublishSubject<URL>()
    let disposeBag = DisposeBag()
    func manageHiddenUI()  {
        loadingIndicatorBehavior.accept(false)//start loading
        searchIconBehavior.accept(true)//hide search icon
        webViewBehavior.accept(false)
    }
    func uploadImageToFirebaseStorage()
    {
        self.manageHiddenUI()
        firebaseManager = FirebaseManager()
        imageDataSubject.asObserver().subscribe { [weak self](imgData) in
            guard let self = self else {return}
            guard let imageData = imgData.element else {return}
            self.firebaseManager.uploadImageToFirebaseStorage(imageData: imageData) { (googleURL) in
                //google method
                self.displayGoogleSearchInWebView(andURL: googleURL)
            }
        }.disposed(by: disposeBag)
        
    }
    func detectImage(image:CIImage)
    {
        //vncoremlmodel is a container of our model and it comes from vision
        guard let model = try? VNCoreMLModel(for:Resnet50(configuration: .init()).model ) else {
            fatalError("loading coreml model failed")
        }
        //vision coreml request
        let request = VNCoreMLRequest(model: model) { [weak self](request, error) in
            guard let self = self else {return}
            guard let classificationFirstResult = request.results?.first as? VNClassificationObservation else {
                fatalError("model failed to process image")
            }
            let accurateValueOfImageClassification = classificationFirstResult.identifier
            self.accurateImageClassificationBehavior.accept(accurateValueOfImageClassification)
        }
        //specify the image we want to classify it
        let handler = VNImageRequestHandler(ciImage:image )
        do {
            try  handler.perform([request])
        } catch  {
            print(error)
        }
    }
    func displayGoogleSearchInWebView(andURL imageURL:String)  {
        accurateImageClassificationBehavior.subscribe { [weak self] (imageClassificationValue) in
            guard let self = self else {return}
            let imageText = imageClassificationValue.element!.encodedURL()
            guard let url = URL(string: "https://www.google.com/searchbyimage?q=\(imageText)&site=search&sa=X&image_url=\(imageURL)") else
            {
                fatalError("nil url")
            }
            self.googleURL.onNext(url)
        }.disposed(by: disposeBag)
    }
    
}
