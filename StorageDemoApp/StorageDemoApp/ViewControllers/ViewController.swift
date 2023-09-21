//
//  ViewController.swift
//  StorageDemoApp
//
//  Created by Nitin Bhatia on 07/09/23.
//

import Cocoa
import CryptoKit

class ViewController: NSViewController {
  
    //outlets
    
    @IBOutlet weak var btniOS: NSButton!
    @IBOutlet weak var btnAndroid: NSButton!
    @IBOutlet weak var btnGit: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func btniOSAction(_ sender: Any) {
        askForCredentials(.iOS, delegateObj: self)
    }
    
    @IBAction func btnAndroidAction(_ sender: Any) {
        askForCredentials(.Android, delegateObj: self)
    }
    
    @IBAction func btnGitAction(_ sender: Any) {
        askForCredentials(.Git, delegateObj: self)
    }

    @IBAction func btnGetBearerToken(_ sender: Any) {
        print(getJWTToken())
    }
}

extension ViewController: SetCredentialsProtocol {
    func didPasswordSet(username: String, password: String) {
       print(password)
    }
}
