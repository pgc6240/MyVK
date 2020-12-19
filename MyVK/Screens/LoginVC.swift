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
        webView                  = WKWebView(frame: UIScreen.main.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
            "revoke"        : "1"
        ]
        urlComponents?.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
        
        if let url = urlComponents?.url {
            webView.load(URLRequest(url: url))
        }
    }
}
