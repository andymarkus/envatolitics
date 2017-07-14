//
//  WebView.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 2/11/15.
//  Copyright (c) 2015 Dongri Jin. All rights reserved.
//

import UIKit
import OAuthSwift

class WebViewController: OAuthWebViewController, UIWebViewDelegate {
    
   
    var targetURL : URL = URL()
    let webView : UIWebView = UIWebView()
    var receivedRequest: URLRequest?;
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.frame = UIScreen.main.applicationFrame
        self.webView.scalesPageToFit = true
        self.webView.delegate = self
        self.view.addSubview(self.webView)
        loadAddressURL()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func setUrl(_ url: URL) {
        targetURL = url
    }
    func loadAddressURL() {
        let req = URLRequest(url: targetURL)
        self.webView.loadRequest(req)
    }
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if (request.url!.scheme == "oauth-swift"){
            receivedRequest = request
            self.dismiss(animated: true, completion: nil)
        }
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        OAuth2Swift.handleOpenURL((receivedRequest?.url)!)
    }
    
}
