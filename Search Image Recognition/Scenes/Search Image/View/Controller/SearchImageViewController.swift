import UIKit
import WebKit
import RxSwift
import RxCocoa

class SearchImageViewController: UIViewController
{
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    private  var searchImageVM:SearchImageViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        searchImageVM = SearchImageViewModel()
        self.subscribeToCameraButton()
        self.bindNavigationItem()
        self.subscribeToGoogleURL()
        self.subscriberToWKNavigationDelegate()
        self.bindVisibilityOfUI()
        self.subscribeToError()
    }
//MARK: - rxswift methods
    func bindNavigationItem()
    {
        searchImageVM.accurateImageClassificationBehavior.bind(to: self.navigationItem.rx.title).disposed(by: disposeBag)
    }
    func subscribeToCameraButton()
    {
        cameraButton.rx.tap.subscribe
        { (_) in
            self.openCamera()
        }.disposed(by: disposeBag)
        
    }
    func subscribeToGoogleURL()
    {
        searchImageVM.googleURLSubject.asObserver().subscribe
        {[weak self] (googleURL) in
            guard let self = self else {return}
            guard let googleURL = googleURL.element
            else
            {
                return
            }
            self.webView.load(URLRequest(url: googleURL))
        } .disposed(by: disposeBag)
    }
    func subscriberToWKNavigationDelegate()
    {
        webView.rx.didFinishLoad.asObservable().subscribe
        { [weak self] (web) in
            guard let self = self else {return}
            self.searchImageVM.loadingIndicatorBehavior.accept(true)
        }.disposed(by: disposeBag)
    }
    func bindVisibilityOfUI()
    {
        searchImageVM.loadingIndicatorBehavior.bind(to: loadingIndicator.rx.isHidden).disposed(by:disposeBag)
        searchImageVM.webViewBehavior.bind(to: webView.rx.isHidden).disposed(by: disposeBag)
        searchImageVM.searchIconBehavior.bind(to: searchIcon.rx.isHidden).disposed(by: disposeBag)
    }
    func subscribeToError()
    {
        searchImageVM.errorMessageSubject.asObservable().subscribe { (errorMessage) in
            guard let errorMessage = errorMessage.element
            else
            {
                return
            }
            self.showAlert(with: errorMessage)
            self.searchImageVM.loadingIndicatorBehavior.accept(true)
            self.searchImageVM.webViewBehavior.accept(true)
            self.searchImageVM.searchIconBehavior.accept(false)
        }.disposed(by: disposeBag)
        
    }
   
    
}

//MARK: - image picker methods
extension SearchImageViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate
{
   
    func openCamera()
    {
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
            searchImageVM.errorMessageSubject.onNext("camera not found")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        dismiss(animated: true, completion: nil)
        searchImageVM.uploadImageToFirebaseStorage()
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        {
            guard let ciImage = CIImage(image: userPickedImage)
            else
            {
                searchImageVM.errorMessageSubject.onNext("error converting picked image to ciimage")
                return
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

