//
//  Extensions.swift
//  AppIconGenerator
//
//  Created by Nitin Bhatia on 08/06/23.
//

import Cocoa

extension NSViewController {
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
}
