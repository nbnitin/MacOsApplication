//
//  KeyChainWrapper.swift
//  StorageDemoApp
//
//  Created by Nitin Bhatia on 07/09/23.
//

import Foundation
import AuthenticationServices
import CryptoKit

extension OSStatus {

    var error: NSError? {
        guard self != errSecSuccess else { return nil }

        let message = SecCopyErrorMessageString(self, nil) as String? ?? "Unknown error"

        return NSError(domain: NSOSStatusErrorDomain, code: Int(self), userInfo: [
            NSLocalizedDescriptionKey: message])
    }
}

final class Storages {
    
    static let shared = Storages()
    
    private init(){}
    
    func save(_ data: Data, service: String, account: String, comment: String = "Platform Team") {
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecAttrComment: comment,
        ] as CFDictionary
            
        let saveStatus = SecItemAdd(query, nil)
     
        if saveStatus != errSecSuccess {
            print("Error: \(saveStatus)")
        }
        
        if saveStatus == errSecDuplicateItem {
            update(data, service: service, account: account, comment: comment)
        }
    }
    
    func update(_ data: Data, service: String, account: String, comment:String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ] as CFDictionary
            
        let updatedData = [kSecAttrComment: comment, kSecValueData: data] as CFDictionary
        SecItemUpdate(query, updatedData)
    }
     
    func read(service: String, account: String) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true
        ] as CFDictionary
            
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        return result as? Data
    }
    
    func read(service: String) -> AnyObject? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            //kSecReturnData: true, //data wont work with limit all
            kSecReturnAttributes: true,
            kSecMatchLimit: kSecMatchLimitAll
        ] as CFDictionary
            
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        return result
    }
    
//    func readKeys(account: String) {
//        let query = [
//            kSecClass: kSecClassIdentity,
//            kSecReturnAttributes: true,
//            kSecMatchLimit: kSecMatchLimitAll
//        ] as CFDictionary
//
//        var result: AnyObject?
//        SecItemCopyMatching(query, &result)
//        print(result)
//        //return result
//    }
//
    func delete(service: String, account: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
            
        SecItemDelete(query)
    }
    
    
    func getPrivateKey() -> SymmetricKey {
        let key = getPublicKey()
        if let keyData = UserDefaults.standard.privateKey {
            let symmetricKey = try! AES.KeyWrap.unwrap(keyData, using: key)
            return symmetricKey
        }
        let data = setPrivateKey()
        let symmetricKey = try! AES.KeyWrap.unwrap(data, using: key)
        return symmetricKey
    }
        
    
    private func setPrivateKey() -> Data {
        let key = getPublicKey()
        let privateKey = SymmetricKey(size: .bits256)
        let encryptedPrivateKey = try? AES.KeyWrap.wrap(privateKey, using: key)
        UserDefaults.standard.privateKey = encryptedPrivateKey
        return encryptedPrivateKey!
    }
    
    private func getPublicKey() -> SymmetricKey {
        if let keyData = UserDefaults.standard.publicKey {
            let symmetricKey = SymmetricKey(data: keyData)
            return symmetricKey
        }
        let data = setPublicKey()
        let symmetricKey = SymmetricKey(data: data)
        return symmetricKey
        
    }
    
    private func setPublicKey() -> Data {
        let publicKey = String.random(length: 32)
        let r = publicKey.toHexEncodedString()
        let data =  Data(hexString: r)
        UserDefaults.standard.publicKey = data
        return data!
    }
    
    //MARK: encrypt data
    func encryptData(_ data:String, key: SymmetricKey)->Data {
        let data = data.data(using: .utf8)!
        let encryptedSealedBox = try! AES.GCM.seal(data, using: key)// mark 3
//        debugPrint("Ecrypted Sealed Box Base64 text -> \(encryptedSealedBox.ciphertext.base64EncodedString())")
        return encryptedSealedBox.combined!
    }
    
    //MARK: decrypt data
    func deCryptData(_ encryptedData:Data, key: SymmetricKey)-> String {
        // this decryption usually occurs in other system, so you will have to send somehow the symmetric key to it.
        // let cipherText = Data(base64Encoded: text)
        //        let nonce = Data(hexString: "131348c0987c7eece60fc0bc") // = initialization vector
        //        let tag = Data(hexString: "5baa85ff3e7eda3204744ec74b71d523")
        
        do {
            let sealedBox =  try AES.GCM.SealedBox(combined: encryptedData)
            
            let decriptSealedBox = try AES.GCM.open(sealedBox, using: key) // mark 4
            debugPrint("Text decrypted -> ",String(data: decriptSealedBox, encoding: .utf8)!)
            return String(data: decriptSealedBox, encoding: .utf8)!
        } catch {
            return ""
        }
    }
    
}
