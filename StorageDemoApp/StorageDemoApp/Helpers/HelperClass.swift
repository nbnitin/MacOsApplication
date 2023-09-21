//
//  HelperClass.swift
//  StorageDemoApp
//
//  Created by Nitin Bhatia on 21/09/23.
//

import Foundation

//MARK: checks for valid service account json
func isValidServiceAccountJSON(path: String) -> Bool {
    let output = generateJWTToken(path: path)
    return !(output.isEmpty)
}

//MARK: generating JWT Token
func generateJWTToken(path: String) -> String {
    ScriptGenerator.shared.shell(shellScriptName: "accesstoken", shellScriptArguments: "\(path) https://www.googleapis.com/auth/androidpublisher \(Bundle.main.resourcePath! + "\\")").output
}

//MARK: getting json token, which is saved in key chain in encrypted form, we are fetching it here and decrypt it and returing JWT token
func getJWTToken() -> String? {
    let privateKey = Storages.shared.getPrivateKey()
    guard let encryptedData = Storages.shared.read(service: Constants.KEY_CHAIN_WRAPPER , account: Constants.ANDROID_SERVICE_ACCOUNT) else {
        return nil
    }
    let decryptedData = Storages.shared.deCryptData(encryptedData, key: privateKey)
    
    let privateFileToBeWritten = Bundle.main.path(forResource: "AndroidServiceAccount", ofType: ".json")
    
    try? decryptedData.data(using: .utf8)?.write(to: URL(filePath: privateFileToBeWritten!))
    
    let token = generateJWTToken(path: privateFileToBeWritten!)
    
    return token
}


