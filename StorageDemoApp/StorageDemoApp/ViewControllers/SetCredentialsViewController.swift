//
//  SetCredentialsViewController.swift
//  whitelabelling
//
//  Created by Nitin Bhatia on 14/09/23.
//

//this file is used for setting credentials for git, ios and android

import Cocoa
import CryptoKit

enum CredentialType : String {
    case Git
    case iOS
    case Android
}

protocol SetCredentialsProtocol {
    func didPasswordSet(username:String, password: String)
}

class SetCredentialsViewController: NSViewController, NSTextFieldDelegate, NSWindowDelegate {
    
    deinit {
        debugPrint("set credential deinit")
    }
    
    //outlets
    @IBOutlet weak var btnOpenDir: NSButton!
    @IBOutlet weak var containerView: NSView!
    @IBOutlet weak var btnHelp: NSButton!
    @IBOutlet weak var btnTogglePassword: NSButton!
    @IBOutlet weak var stackActionBottom: NSStackView!
    @IBOutlet weak var btnSave: NSButton!
    @IBOutlet weak var btnCancel: NSButton!
    @IBOutlet weak var txtPassword: NSSecureTextField!
    @IBOutlet weak var txtUsername: NSTextField!
    @IBOutlet weak var lblPassword: NSTextField!
    @IBOutlet weak var lblUserName: NSTextField!
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var txtShowPassword: NSTextField!
    @IBOutlet weak var txtUserNameDisabledConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtUserNameEnabledConstraint: NSLayoutConstraint!
    
    //variables
    var credentialType : CredentialType = .Git
    var delegate: SetCredentialsProtocol?
    var keyChainListVC : ListKeyChainViewController!
    var serviceAccountJSONContent: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtShowPassword.isHidden = true
        takeActionAsPerCredentialType(true)
        txtPassword.delegate = self
        txtShowPassword.delegate = self
        txtUsername.delegate = self
        
        
    }
    
    
    override func viewDidAppear() {
        view.window?.standardWindowButton(.zoomButton)?.isEnabled = false
        view.window?.standardWindowButton(.closeButton)?.isEnabled = true
        view.window?.delegate = self
    }
    
    //MARK: window delegate function, should close. here we are deciding based on condition either we should close it or not
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        checkForChanges()
    }
    
    func windowWillClose(_ notification: Notification) {
        //take some action on close if you want
    }
    
    
    //MARK: this function helps to decide either we should close the window or not
    private func checkForChanges() -> Bool {
        if !txtPassword.stringValue.isEmpty && !txtUsername.stringValue.isEmpty {
            let modal = createAlert(title: "Opps", message: "You have some unsaved changes you will loose them, Are you sure you want to close ?", okButtonTitle: "Yes", shouldShowCancelButton: true)
            let alert = modal.runModal()
            
            if alert == NSApplication.ModalResponse.alertFirstButtonReturn {
                return true
            }
            return false
        }
        return true
    }
    
    //MARK: taking action as per credential type
    private func takeActionAsPerCredentialType(_ setView: Bool) {
        switch credentialType {
        case .Git:
            if setView {
                lblTitle.stringValue = "Git Credentials"
                containerView.isHidden = true
                btnOpenDir.removeFromSuperview()
            } else {
                setCredentialsForGit()
            }
        case .iOS:
            if setView {
                lblTitle.stringValue = "App Store Credentials"
                lblUserName.stringValue = "Apple ID"
                txtPassword.placeholderString = "App Specific Password"
                containerView.isHidden = false
                btnOpenDir.removeFromSuperview()
            } else {
                setCredentialsForiOS()
            }
        case .Android:
            if setView {
                lblTitle.stringValue = "Play Store Credentials"
                lblUserName.stringValue = "Please select the JSON file of Service Account"
                txtUsername.placeholderString = "Plesae select"
                txtUsername.isEditable = false
                txtUsername.isEnabled  = false
                containerView.isHidden = true
                txtUserNameEnabledConstraint.isActive = false
                txtUserNameDisabledConstraint.isActive = true
                txtPassword.isHidden = true
                txtShowPassword.isHidden = true
                btnTogglePassword.isHidden = true
                lblPassword.isHidden = true
            } else {
                setCredentialsForAndroid()
            }
        }
//        btnCancelAction(btnCancel)
    }
    
    //MARK: this function we will be fired on every change in text fields
    func controlTextDidChange(_ obj: Notification) {
        if let txt = obj.object as? NSSecureTextField, txt == txtPassword {
            txtShowPassword.stringValue = txt.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let txt = obj.object as? NSTextField, txt == txtShowPassword {
            txtPassword.stringValue = txt.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if !txtPassword.stringValue.isEmpty && !txtUsername.stringValue.isEmpty {
            btnSave.isEnabled = true
        } else {
            btnSave.isEnabled = false
        }
        
//        if credentialType != .Android {
//            btnSave.isEnabled = !txtPassword.stringValue.isEmpty && !txtUsername.stringValue.isEmpty
//        } else {
//            btnSave.isEnabled = !txtUsername.stringValue.isEmpty
//        }
//
    }
    
    //MARK: settig credentials for git
    private func setCredentialsForGit() {
        let command = "security add-internet-password -a '\(txtUsername.stringValue)' -s gitlab.com -l gitlab.com -r htps -U -w \(txtPassword.stringValue)"
        _ = ScriptGenerator.shared.shell(command)
        delegate?.didPasswordSet(username: txtUsername.stringValue, password: txtPassword.stringValue)
    }
    
    //MARK: settig credentials for iOS
    private func setCredentialsForiOS() {
        let privateKey = Storages.shared.getPrivateKey()
        let encryptedData = Storages.shared.encryptData(txtPassword.stringValue,key: privateKey)
        Storages.shared.save(encryptedData, service: Constants.KEY_CHAIN_WRAPPER, account: txtUsername.stringValue, comment: "")
//        let p = Storages.shared.read(service: KEY_CHAIN_WRAPPER)
//        deCryptData(text: p, key: privateKey)
        
        keyChainListVC.setTableView()
    }
    
    //MARK: settig credentials for android
    private func setCredentialsForAndroid() {
        let privateKey = Storages.shared.getPrivateKey()
        let encryptedData = Storages.shared.encryptData(serviceAccountJSONContent,key: privateKey)
        Storages.shared.save(encryptedData, service: Constants.KEY_CHAIN_WRAPPER, account: Constants.ANDROID_SERVICE_ACCOUNT, comment: "")
        getJWTToken()
    }
    
    //MARK: help button action, it will be redirected to instruction screen
    @IBAction func btnHelpAction(_ sender: Any) {
       
      print("show help here")
    }
    
    //MARK: save button action
    @IBAction func btnSaveAction(_ sender: Any) {
        takeActionAsPerCredentialType(false)
        txtPassword.stringValue = ""
        txtUsername.stringValue = ""
        txtShowPassword.stringValue = ""
    }
    
    //MARK: cancel button action
    @IBAction func btnCancelAction(_ sender: Any) {
        if checkForChanges() {
            view.window?.close()
        }
    }
    
    //MARK: btn toggle password action, it will hide show the password secure entry
    @IBAction func btnTogglePasswordAction(_ sender: Any) {
        if !txtPassword.isHidden {
            txtPassword.isHidden = true
            txtShowPassword.isHidden = false
            btnTogglePassword.image = NSImage(systemSymbolName: "eye.slash", accessibilityDescription: nil)
            
            if txtShowPassword.stringValue.isEmpty {
                txtShowPassword.stringValue = txtPassword.stringValue
            }
            
        } else {
            txtPassword.isHidden = false
            txtShowPassword.isHidden = true
            btnTogglePassword.image = NSImage(systemSymbolName: "eye", accessibilityDescription: nil)
        }
    }
    
    //MARK: btn open action, open the dialog to let user select the file
    @IBAction func btnOpenAction(_ sender: Any) {
        let dialog = NSOpenPanel();
        dialog.title                   = "Please Select Your JSON File"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        
        if ( dialog.runModal() ==  NSApplication.ModalResponse.OK ) {
            var result = ""
            
            dialog.urls.forEach({
                result += $0.path() + ";"
            })
            
            result.removeLast()
            
            if !result.isEmpty {
                let path: String = result
                let projectPath = path.hasSuffix("/") ? path : (path + "/")
                txtUsername.stringValue = projectPath.dropLast().replacingOccurrences(of: "%20", with: " ")
                
                if !isValidServiceAccountJSON(path: String(projectPath.dropLast())) {
                    showAlert(title: "Oops", message: "Not a valid Service Account JSON file")
                    txtUsername.stringValue = ""
                    btnOpenDir.image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
                    btnSave.isEnabled = false
                } else {
                    btnSave.isEnabled = true
                    btnOpenDir.image = NSImage(systemSymbolName: "folder.fill", accessibilityDescription: nil)
                    serviceAccountJSONContent = try! String(contentsOfFile: txtUsername.stringValue)
                    setCredentialsForAndroid()
                }
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    //MARK: communicating with container view
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "keyChainList" {
            keyChainListVC = segue.destinationController as? ListKeyChainViewController
        }
    }
    
    
}
