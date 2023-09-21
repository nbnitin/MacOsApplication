//
//  ScriptGenerator.swift
//  whitelabelling
//
//  Created by Nitin Bhatia on 15/06/23.
//

//This file helps to run shell scripts, or shell commands

import Foundation
import Cocoa

protocol ScriptGeneratorProtocol: AnyObject {
    func didPathSet()
}

class ScriptGenerator {
    //variables
    var sysPath : String = String()
    var password: String = String()
    static let shared = ScriptGenerator()
    private let path = Bundle.main.resourcePath
    weak var delegate: ScriptGeneratorProtocol?
    
    private init() {}
    
    @discardableResult // Add to suppress warnings when you don't want/need a result
    func runScript(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        //        task.launchPath = lblProjectFolder.stringValue
        task.executableURL = URL(fileURLWithPath: "/bin/zsh") //<--updated
        task.standardInput = nil
        
        try task.run() //<--updated
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
    
    func shell(_ args: String? = nil, shellScriptName: String? = nil, shellScriptArguments: String? = nil) -> (output:String, taskStatus:Int32) {
        
        var taskArguments : [String]
        
        if let args = args {
            if args.lowercased().contains("sudo") && password.isEmpty {
                askForPassword()
            }
            taskArguments = ["-c", args]
        } else {
            taskArguments = ["-c", "source \(Bundle.main.path(forResource: shellScriptName!, ofType: ".sh")!) \(shellScriptArguments!)"]
        }
        
        if sysPath == "" {
            setSysPath()
        }
        
        let passwordWithNewline = password + "\n"
        let task = Foundation.Process()
        
        //task.launchPath = "/bin/zsh"
        //task.launch()
        task.arguments = taskArguments
        //task.arguments = task.arguments! + args
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        //        task.launchPath = "/bin/zsh"
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
        //        print(output)
        if error != "" {
            print("Ran into error while running: \(error)")
        }
        task.waitUntilExit()
        return (output, task.terminationStatus)
        
    }
    
    func setSysPath() {
        
        if let contents = try? String(contentsOfFile: path! + "/" + "Path.text"), contents != "" {
            sysPath = contents.trimmingCharacters(in: .newlines)
            delegate?.didPathSet()
        } else {
            let myGroup = DispatchGroup()
            
            myGroup.enter()
            try! runScript("cd \(path!) && sh ./TerminateScript.sh")
            try! runScript("cd \(path!) && sh ./GetSysPath.sh")
            sysPath = try! runScript("cd ~ && cd Desktop && cat path.text")
            
            let url = URL(filePath: path! + "/" + "Path.text")
            
            try? sysPath.trimmingCharacters(in: .newlines).data(using: .utf8)?.write(to:  url)
            
            print( FileManager.default.contents(atPath: path! + "/" + "Path.text") )
            
            sysPath = sysPath.trimmingCharacters(in: .newlines)
            myGroup.leave()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
                try! self.runScript("cd ~ && cd Desktop && rm Path.text ")
                try! self.runScript("cd \(self.path!) && sh ./TerminateScript.sh")
            })
            
            myGroup.notify(queue: .main) {
                self.delegate?.didPathSet()
            }
            //delegate?.didPathSet()
        }
        
        
        
        
        //sysPath += ":/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home"
        //        let task = Foundation.Process()
        //        task.launchPath = "/usr/bin/env"
        //        task.arguments = ["/bin/bash","-c","cd \(path!) && sh ./GetSysPath.sh"]
        //
        //        let outputPipe = Pipe()
        //        task.standardOutput = outputPipe
        //        task.standardInput = nil
        //        task.launch()
        //        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        //        sysPath = String(bytes: outputData, encoding: .utf8) ?? ""
        //
        
        
        //        let task = Foundation.Process()
        //        task.launchPath = "/usr/bin/env"
        //        task.arguments = ["/bin/bash","-c","eval $(/usr/libexec/path_helper -s) ; echo $PATH"]
        //
        //        let outputPipe = Pipe()
        //        task.standardOutput = outputPipe
        //        task.standardInput = nil
        //        task.launch()
        //        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        //        sysPath = String(bytes: outputData, encoding: .utf8) ?? ""
        
        
        
        //        let output = try? runScript("printenv")
        //        let seperatedOutput = output?.components(separatedBy: .newlines)
        //        if let indexOfPath = seperatedOutput?.firstIndex(where: {$0.contains("PATH=")}) {
        //            sysPath = seperatedOutput?[indexOfPath].components(separatedBy: "=").last ?? ""
        //        }
        //
        
        
        
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
