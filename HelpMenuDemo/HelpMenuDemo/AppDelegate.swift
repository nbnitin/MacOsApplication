//
//  AppDelegate.swift
//  HelpMenuDemo
//
//  Created by Nitin Bhatia on 10/08/23.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        //NSHelpManager.shared.registerBooks(in: Bundle.main)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

