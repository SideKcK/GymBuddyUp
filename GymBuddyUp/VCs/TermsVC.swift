//
//  TermsVC.swift
//  GymBuddyUp
//
//  Created by YiHuang on 15/11/2016.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class TermsVC: UIViewController, UIWebViewDelegate {
    var webView : UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Terms of Services"
        webView = UIWebView(frame: view.frame)
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.sidekckapp.com/SideKcKEULA.html")!))
        webView.delegate = self
        view.addSubview(webView)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
