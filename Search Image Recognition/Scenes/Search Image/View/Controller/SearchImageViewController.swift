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
    var searchImageVM:SearchImageViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchImageVM = SearchImageViewModel()
        self.subscribeToCameraButton()
        self.bindNavigationItem()
        self.subscribeToGoogleURL()
        self.subscriberToWKNavigationDelegate()
        self.bindVisibilityOfUI()
    }
    
}
//MARK: - rxswift methods
extension SearchImageViewController
{
    func bindNavigationItem()  {
        searchImageVM.accurateImageClassificationBehavior.bind(to: self.navigationItem.rx.title).disposed(by: disposeBag)
    }
    func subscribeToCameraButton() {
        cameraButton.rx.tap.subscribe { (_) in
            self.openCamera()
        }.disposed(by: disposeBag)
        
    }
    func subscribeToGoogleURL() {
        searchImageVM.googleURL.asObserver().subscribe {[weak self] (googleURL) in
            guard let self = self else {return}
            guard let googleURL = googleURL.element else {fatalError("error to subscribing google url")}
            self.webView.load(URLRequest(url: googleURL))
        } .disposed(by: disposeBag)
    }
    func subscriberToWKNavigationDelegate()  {
        webView.rx.didFinishLoad.asObservable().subscribe { [weak self] (web) in
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
    
}




