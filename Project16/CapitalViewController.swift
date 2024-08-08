//
//  CapitalViewController.swift
//  Project16
//
//  Created by Leo on 2024-07-11.
//

import UIKit
import WebKit

class CapitalViewController: UIViewController, WKNavigationDelegate {

    static let identifier = "CapitalWikiView"
    
    var webView: WKWebView!
    var capital: String!
    
    override func loadView() {
    
        webView = WKWebView()
        webView.navigationDelegate = self
        
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let capital = capital else {
            return
        }
        
        navigationController?.navigationItem.title = capital
        
        let stringUrl = "wikipedia.org/wiki/\(capital.replacingOccurrences(of: " ", with: ""))"
        print(stringUrl)
        guard let url = URL(string: "wikipedia.org/wiki/Washington,_D.C.") else {
            print("Unable to create an url")
            return
        }
        webView.load(URLRequest(url: url))
    }
}
