//
//  LoginVC.swift
//  MyVK
//
//  Created by pgc6240 on 19.12.2020.
//

import UIKit
import WebKit

final class LoginVC: UIViewController {
    
    private var webView: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
    }
    
    
    private func configureWebView() {
        webView                     = WKWebView(frame: UIScreen.main.bounds)
        webView.autoresizingMask    = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate  = self
        view.addSubview(webView)
        
        loadAuthPage()
    }
    
    
    private func loadAuthPage() {
        var urlComponents = URLComponents(string: "https://oauth.vk.com/authorize")
        let parameters    = [
            "client_id"     : "7704322",
            "redirect_uri"  : "https://oauth.vk.com/blank.html",
            "display"       : "mobile",
            "scope"         : "262150",
            "response_type" : "token",
            "state"         : "pgc6240",
            "revoke"        : "0"
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
        
        guard let url = navigationResponse.response.url, url.path == "/blank.html", let fragment = url.fragment else {
            decisionHandler(.allow)
            return
        }
        
        let parameters = fragment
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) {
                var parameters    = $0
                parameters[$1[0]] = $1[1]
                return parameters
            }
        
        SessionManager.login(token: parameters["access_token"], usedId: parameters["user_id"])
        
        decisionHandler(.cancel)
    }
}
