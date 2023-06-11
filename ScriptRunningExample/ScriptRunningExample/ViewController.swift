//
//  ViewController.swift
//  Script Running Example
//
//  Created by Nitin Bhatia on 08/06/23.
//

import Cocoa

class ViewController: NSViewController {
    
    //outlets
    @IBOutlet var txtView: NSTextView!
    @IBOutlet weak var btnStartProcess: NSButton!
    
    //variables
    var sysPath : String = String()
    var password: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtView.isEditable = false
        txtView.isSelectable = false
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    @IBAction func btnCreateProcessAction(_ sender: Any) {
        btnStartProcess.isEnabled = false
        txtView.string = ""
        self.txtView.string += "process started...\n"
        setSysPath()
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10, execute: {
        self.txtView.string += "Ruunning ... \n"
        
        self.txtView.string += self.shell("cd ~ && cd Documents/ && ls").output
        
        self.txtView.string += self.shell("cd ~ && cd Desktop && ls -a").output
        
        self.txtView.string += "Bye..."
        btnStartProcess.isEnabled = true
        // })
        
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
    func shell(_ args: String) -> (output:String, taskStatus:Int32) {
        
        if args.lowercased().contains("sudo") {
            askForPassword()
        }
        
        let passwordWithNewline = password + "\n"
        let task = Foundation.Process()
        
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        //task.launchPath = "/bin/zsh"
        //task.launch()
        task.arguments = ["-c", args]
        //task.arguments = task.arguments! + args
        //task.launchPath = "/usr/bin/sudo"
        
        //Set environment variables
        var environment = ProcessInfo.processInfo.environment
        environment["PATH"] = sysPath
        
        //environment["CREDENTIALS"] = "/path/to/credentials"
        task.environment = environment
        
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.standardInput = inputPipe
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        
        do {
            try task.run()
        } catch {
            // handle errors
            print("Error: \(error.localizedDescription)")
        }
        
        // Show the output as it is produced
        
        
        outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            
            let data = fileHandle.availableData
            if (data.count == 0) { return }
            print("read \(data.count)")
            print("\(String(bytes: data, encoding: .utf8) ?? "<UTF8 conversion failed>")")
        }
        
        // Write the password
        inputPipe.fileHandleForWriting.write(passwordWithNewline.data(using: .utf8)!)
        
        // Close the file handle after writing the password; avoids a
        // hang for incorrect password.
        try? inputPipe.fileHandleForWriting.close()
        
        
        
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)
        let error = String(decoding: errorData, as: UTF8.self)
        
        
        
        //Log or return output as desired
        print(output)
        print("Ran into error while running: \(error)")
        task.waitUntilExit()
        return (output, task.terminationStatus)
        
    }
    
    func setSysPath() {
        let task = Foundation.Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["/bin/bash","-c","sudo eval $(/usr/libexec/path_helper -s) ; echo $PATH"]
        
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardInput = nil
        task.launch()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        sysPath = String(bytes: outputData, encoding: .utf8) ?? ""
    }
    
    
    func checkPassword(password: String) -> Bool {
        var isPasswordCorrect : Bool = false
        let password = password
        let passwordWithNewline = password + "\n"
        let sudo = Process()
        sudo.launchPath = "/usr/bin/sudo"
        sudo.arguments = ["-S", "/bin/ls"]
        let sudoIn = Pipe()
        let sudoOut = Pipe()
        sudo.standardOutput = sudoOut
        sudo.standardError = sudoOut
        sudo.standardInput = sudoIn
        sudo.launch()
        
        //        // Show the output as it is produced
        //        sudoOut.fileHandleForReading.readabilityHandler = { fileHandle in
        //            let data = fileHandle.availableData
        //            if (data.count == 0) { return }
        //            print("read \(data.count)")
        //            print("\(String(bytes: data, encoding: .utf8) ?? "<UTF8 conversion failed>")")
        //
        //
        //        }
        // Write the password
        sudoIn.fileHandleForWriting.write(passwordWithNewline.data(using: .utf8)!)
        
        // Close the file handle after writing the password; avoids a
        // hang for incorrect password.
        try? sudoIn.fileHandleForWriting.close()
        
        // Make sure we don't disappear while output is still being produced.
        sudo.waitUntilExit()
        let outputData = sudoOut.fileHandleForReading.readDataToEndOfFile()
        if !(String(bytes: outputData, encoding: .utf8) ?? "<UTF8 conversion failed>").contains("incorrect password") {
            isPasswordCorrect = true
        }
        
        return isPasswordCorrect
        print("Process did exit")
    }
    
    
    func askForPassword(isReattempting : Bool = false) {
        let passTest = createPasswordAlert(isReattempting: isReattempting)
        
        
        if !passTest.status {
            askForPassword(isReattempting: true)
        }
        password = passTest.passwordText
        return
    }
    
    
    func createPasswordAlert(isReattempting: Bool = false) -> (status:Bool, passwordText: String) {
        let alert = NSAlert()
        alert.messageText = isReattempting ? "The entered password is incorrect, please re-enter the password" : "Please enter your password"
        let textView = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: alert.window.frame.width, height: 30))
        alert.accessoryView = textView
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Exit")
        let modal = alert.runModal()
        
        if modal == NSApplication.ModalResponse.alertFirstButtonReturn {
            return (checkPassword(password: textView.stringValue), textView.stringValue)
        } else if modal == .alertSecondButtonReturn {
            NSApplication.shared.terminate(nil)
        }
        return (true,"")
    }
}

