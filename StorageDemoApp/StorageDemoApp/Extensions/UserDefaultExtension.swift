//
//  UserDefaultExtension.swift
//  StorageDemoApp
//
//  Created by Nitin Bhatia on 21/09/23.
//

import Foundation
//this is act as helper class for userdefaults

import Foundation
let USER_DEFUALT_OPT_OUT_FROM_CLEAN : [UserDefaultsKeys] = []

enum UserDefaultsKeys : String,CaseIterable {
    case privateKey = "privateKey"
    case publicKey = "publicKey"
}

extension UserDefaults {
    class func clearUserDefaults() {
        UserDefaultsKeys.allCases.forEach({
            if !USER_DEFUALT_OPT_OUT_FROM_CLEAN.contains($0) {
                UserDefaults.standard.removeObject(forKey: $0.rawValue)
            }
        })
    }
    
    class func clearUserDefaults(_ forKey: UserDefaultsKeys) {
        UserDefaults.standard.removeObject(forKey: forKey.rawValue)
    }
    
    class func clearUserDefaults(_ forKey: [UserDefaultsKeys]) {
        let _ = forKey.map({
            UserDefaults.standard.removeObject(forKey: $0.rawValue)
        })
    }
    
    
    //MARK: private key user default, this will be used in encryption and decryption of data
    var privateKey: Data? {
        get {
            if UserDefaults.standard.value(forKey: UserDefaultsKeys.privateKey.rawValue) == nil {
                return nil
            }
            return UserDefaults.standard.data(forKey: UserDefaultsKeys.privateKey.rawValue)
        }
        set(newValue) {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.privateKey.rawValue)
            } else {
                UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKeys.privateKey.rawValue)
            }
        }
    }
    
    //MARK: public key user default, this will be used in encryption and decryption of private key
    var publicKey: Data? {
        get {
            if UserDefaults.standard.value(forKey: UserDefaultsKeys.publicKey.rawValue) == nil {
                return nil
            }
            return UserDefaults.standard.data(forKey: UserDefaultsKeys.publicKey.rawValue)
        }
        set(newValue) {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.publicKey.rawValue)
            } else {
                UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKeys.publicKey.rawValue)
            }
        }
    }
    
    
}
