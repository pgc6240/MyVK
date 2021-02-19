//
//  LoginVC.swift
//  MyVK
//
//  Created by pgc6240 on 19.12.2020.
//

import UIKit
import WebKit
import Alamofire

final class LoginVC: UIViewController {
    
    @IBOutlet private weak var webView: WKWebView!
    
    @IBOutlet private weak var appLogoImageView: UIImageView!
    
    private let networkReachabilityManager = NetworkReachabilityManager(host: "yandex.ru")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        startObservingNetworkStatus()
    }
    
    
    private func configureViewController() {
        webView.navigationDelegate = self
        appLogoImageView.image = UIImage(named: "AppIcon60x60")
        appLogoImageView.layer.cornerRadius = 15
        appLogoImageView.alpha = 0
        UIView.transition(with: appLogoImageView, duration: 2, options: [.allowUserInteraction]) {
            self.appLogoImageView.alpha = 0.75
        }
    }
    
    
    private func startObservingNetworkStatus() {
        networkReachabilityManager?.startListening { [weak self] status in
            switch status {
            case .reachable(_):
                self?.showLoadingView()
                self?.loadAuthPage()
            case .notReachable:
                self?.presentNetworkUnavailableAlert()
            default: break
            }
        }
    }
    
    
    private func loadAuthPage() {
        var urlComponents = URLComponents(string: "https://oauth.vk.com/authorize")
        let parameters    = [
            "client_id"     : PersistenceManager.appId,
            "redirect_uri"  : "https://oauth.vk.com/blank.html",
            "display"       : "mobile",
            "scope"         : "wall,friends,photos,groups,likes",
            "response_type" : "token",
            "state"         : "pgc6240",
            "revoke"        : SessionManager.loggingOut ? "1" : "0",
            "lang"          : Locale.identifierShort
        ]
        urlComponents?.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
        
        if let url = urlComponents?.url {
            webView.load(URLRequest(url: url))
        }
    }
}


//
// MARK: - WKNavigationDelegate
//
extension LoginVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        var responsePolicy: WKNavigationResponsePolicy?
        defer {
            dismissLoadingView()
            appLogoImageView.alpha = 0
            decisionHandler(responsePolicy ?? .allow)
        }
        
        guard let url = navigationResponse.response.url else {
            return
        }
        
        if url.path == "/blank.html", let fragment = url.fragment {
            
            let parameters = fragment
                .components(separatedBy: "&")
                .map { $0.components(separatedBy: "=") }
                .reduce([String: String]()) {
                    var parameters    = $0
                    parameters[$1[0]] = $1[1]
                    return parameters
                }
            
            SessionManager.login(token: parameters["access_token"], userId: parameters["user_id"])
            performSegue(withIdentifier: "loginSegue", sender: nil)
            
            responsePolicy = .cancel
            
        } else if url.path == "/error", let newAppId = C.APP_IDS.randomElement() {

            PersistenceManager.appId = newAppId
            loadAuthPage()
        }
    }
}
