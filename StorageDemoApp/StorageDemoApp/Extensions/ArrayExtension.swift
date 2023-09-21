//
//  ArrayExtension.swift
//  StorageDemoApp
//
//  Created by Nitin Bhatia on 21/09/23.
//

import Foundation

public extension Sequence where Element : Hashable {
    func contains(_ elements: [Element]) -> Bool {
        return Set(elements).isSubset(of:Set(self))
    }
}

extension Sequence where Iterator.Element == [String: Any] {

    func filterForAppleAccount() -> [[String:Any]] {
        return self.filter({
            $0["acct"] as! String != Constants.ANDROID_SERVICE_ACCOUNT
        })
    }
    
}
