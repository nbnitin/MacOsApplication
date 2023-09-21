//
//  StringExtension.swift
//  StorageDemoApp
//
//  Created by Nitin Bhatia on 21/09/23.
//

import Foundation

extension String {
  func toHexEncodedString(uppercase: Bool = true, prefix: String = "", separator: String = "") -> String {
      return unicodeScalars.map { prefix + .init($0.value, radix: 16, uppercase: uppercase) } .joined(separator: separator)
    }
  static func random(length: Int = 20) -> String {
      let base = "abcdefghijklmnopqrstuvwxyz0123456789"
      var randomString: String = ""
      for _ in 0..<length {
        let randomValue = arc4random_uniform(UInt32(base.count))
        randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
      }
      return randomString
    }
}
