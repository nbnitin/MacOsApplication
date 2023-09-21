//
//  ViewControllerExtension.swift
//  StorageDemoApp
//
//  Created by Nitin Bhatia on 21/09/23.
//

import Foundation
import Cocoa

enum StoryboardName : String {
    case Main = "Main"
}

enum ViewControllerName : String {
   
    case SetCredentialVC = "setCredentialsVC"
   
}


extension NSViewController {
    
    //MARK: ask for credentials
    func askForCredentials(_ credentialType: CredentialType, delegateObj: SetCredentialsProtocol) {
        let vc = SetCredentialsViewController.instantiateFromStoryboard(storyboardName: .Main, storyboardId: .SetCredentialVC)
        vc.delegate = delegateObj
        vc.credentialType = credentialType
        presentAsModalWindow(vc)
    }
    
   
    //MARK: initiating the given VC
    class func instantiateFromStoryboard(storyboardName: StoryboardName, storyboardId: ViewControllerName) -> Self {
        return instantiateFromStoryboardHelper(storyboardName: storyboardName.rawValue, storyboardId: storyboardId.rawValue)
    }
    
    private class func instantiateFromStoryboardHelper<T>(storyboardName: String, storyboardId: String) -> T {
        let storyboard = NSStoryboard(name: storyboardName, bundle: nil)
        let controller = storyboard.instantiateController(withIdentifier: storyboardId) as! T
        return controller
    }
    
    //MARK: creating alert
    func createAlert(title: String, message: String, okButtonTitle: String, shouldShowCancelButton: Bool = false, alertStyle: NSAlert.Style = .informational) -> NSAlert {
        let alert = NSAlert()
        
        alert.messageText = title
        
        alert.informativeText = message
        
        alert.addButton(withTitle: okButtonTitle)
        
        if shouldShowCancelButton {
            alert.addButton(withTitle: "Cancel")
        }
        
        alert.alertStyle = alertStyle
        
        return alert
    }
    
    // MARK: Custom Alert without action
    func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "Done")
        alert.alertStyle = .informational
        alert.runModal()
    }
    
}
