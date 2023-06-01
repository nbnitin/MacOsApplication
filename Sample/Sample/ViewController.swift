//
//  ViewController.swift
//  Sample
//
//  Created by Nitin Bhatia on 10/05/23.
//

import Cocoa
import UniformTypeIdentifiers

//let PATH = "/Users/nitinbhatia/Desktop/myApp/myApp.xcodeproj/project.pbxproj"

class ViewController: NSViewController, NSTextFieldDelegate {
    
    //outlets
    @IBOutlet weak var loadingView: NSView!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    @IBOutlet weak var lblProjecctLocationPath: NSTextField!
    @IBOutlet weak var txtRunScriptName: NSTextField!
    @IBOutlet weak var btnReset: NSButton!
    @IBOutlet weak var btnAddScript: NSButton!
    @IBOutlet weak var txtShellScript: NSTextField!
    @IBOutlet weak var btnRemove: NSButton!
    @IBOutlet weak var btnAddMore: NSButton!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputFilesStackView: NSStackView!
    @IBOutlet weak var bottomView: NSView!
    @IBOutlet weak var btnSelectProjectLocation: NSButton!
    
    //variables
    var initialHeight : CGFloat = 0
    var height : CGFloat = 0
    var mainContent = ""
    var gradient = CAGradientLayer()
    var subviewFrame : CGRect!
    let fileManager = FileManager.default
    var path : String = ""
    var buildActionMask : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gradient.colors = [
          NSColor.darkGray.cgColor,
          NSColor.gray.cgColor,
          NSColor.red.withAlphaComponent(0.4).cgColor
        ]
        gradient.type = .axial
        scrollView.wantsLayer = true
        scrollView.layer?.addSublayer(gradient)
        txtShellScript.delegate = self
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
  
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if initialHeight == 0 {
            initialHeight = self.scrollView.frame.height
            addAddNewTextField()
        }
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        subviewFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.bounds.width, height: 30))
        gradient.frame = subviewFrame
    }
    
    //MARK: text field delegate
    func controlTextDidChange(_ obj: Notification) {
        if let tempObj = obj.object as? NSTextField {
            btnAddScript.isEnabled = !tempObj.stringValue.isEmpty
        }
    }
    
    //MARK: helps to create input paths
    private func getInputPaths() -> String {
        var inputPathStringCollection : [String] = [String]()
        inputFilesStackView.arrangedSubviews.forEach({
            let txt = $0 as! NSTextField
            if !txt.stringValue.isEmpty {
                inputPathStringCollection.append("\"\(txt.stringValue) \"")
            }
        })
        if inputPathStringCollection.isEmpty {
            return "\n"
        }
        let inputPathString = inputPathStringCollection.joined(separator: ",\n")
        return inputPathString
    }
    
    //MARK: helps to create complete build phases and help to refer it to targets as well
    func readFileFromPath() {
        
        
        var ids = [String]()
        //${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run
        //${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}
        //$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)
        
        if fileManager.fileExists(atPath: path) {
            
            let _ = fileManager.contents(atPath:  path)
            let tempString = try! String(contentsOfFile: path, encoding: .utf8)
            mainContent = tempString
            // Append the countries from the string to the dataArray array by breaking them using the line change character.
            var dataArray = tempString.components(separatedBy: "/* Begin PBXNativeTarget section */")
            var newDataArray = dataArray.last?.components(separatedBy: "/* End PBXNativeTarget section */")
            var searchBuildPhases = newDataArray?.first?.components(separatedBy: ";")
            setBuildActionMask(sourceString: dataArray.first)
            
            for index in 0 ..< searchBuildPhases!.count  {
                if searchBuildPhases![index].contains("buildPhases = (") {
                    if canAdd(str: searchBuildPhases![index]) {
                        var nn = searchBuildPhases![index].components(separatedBy: ",")
                        let oldId = (nn[nn.count - 2]).components(separatedBy: "/*").first!
                        let newID = getNewId(id: oldId)
                        ids.append(newID)
                        nn.insert("\n\t\t\t\t \(newID) /* ShellScript1 */", at: nn.count - 2)
                        searchBuildPhases![index] = nn.joined(separator: ",")
                    }
                }
            }
            
            newDataArray![0] = searchBuildPhases!.joined(separator: ";")
            dataArray[1] = newDataArray!.joined(separator: "/* End PBXNativeTarget section */")
            dataArray.insert("/* Begin PBXNativeTarget section */", at: 1)
            var newP = String()
            
            dataArray.forEach({
                newP += $0
                newP += "\n"
            })
            
            
            if newP.contains("/* Begin PBXShellScriptBuildPhase section */") { //check if there is already some script section added already if not then we will add new script section
                dataArray.removeAll()
                dataArray = newP.components(separatedBy: "/* Begin PBXShellScriptBuildPhase section */")
            } else {
                dataArray.insert("/* End PBXShellScriptBuildPhase section */ \n", at: dataArray.count - 2)
            }
           
            let buildPhaseString = getBuildPhaseString()
            
            for id in ids {
                dataArray.insert(buildPhaseString.replacingOccurrences(of: "{{ids}}", with: id), at: 1)
            }
            
            dataArray.insert("/* Begin PBXShellScriptBuildPhase section */", at: 1)
            newP = String()
            
            dataArray.forEach({
                newP += $0
                newP += "\n"
            })
            
            fileManager.createFile(atPath: path, contents: newP.data(using: .utf8))
            loadingView.isHidden = true
            loadingIndicator.isHidden = true
            
            let alert = self.createAlert(title: "Success", message: "Script added to all targets", okButtonTitle: "Ok")
            let modalResult = alert.runModal()
            clearAllStackView()
        }
    }
    
    //MARK: set build action mask number
    func setBuildActionMask(sourceString : String?) {
        let seperatedString = sourceString?.components(separatedBy: ";")
        if let buildMask = seperatedString?.first(where: {$0.contains("buildActionMask")}) {
            self.buildActionMask = buildMask
        }
    }
    
    //MARK: helps to get updated build phase string
    func getBuildPhaseString() -> String {
        return """
        {{ids}} /* \(txtShellScript.stringValue) */ = {
        isa = PBXShellScriptBuildPhase;
        \(buildActionMask);
        files = (
        );
        inputFileListPaths = (
        );
        inputPaths = (
                                \(getInputPaths())
                    );
        name = "\(txtRunScriptName.stringValue)";
        outputFileListPaths = (
        );
        outputPaths = (
        );
        runOnlyForDeploymentPostprocessing = 0;
        shellPath = /bin/sh;
        shellScript = "\\" \(txtShellScript.stringValue) \\"" ;
        };
        """
        
    }
    
    //MARK: helps to decide either the script can add or not, if same script found, it will try not to add it
    func canAdd(str: String) -> Bool {
        let x = str.components(separatedBy: ",")
        var shouldAdd = true
        x.forEach({
            if $0.contains("Sources") || $0.contains("Frameworks") || $0.contains("Resources") || $0.contains("Embed Frameworks") {
                //do nothing
            } else {
                let p = $0.components(separatedBy: "/*")
                let x = p.first?.trimmingCharacters(in: .whitespacesAndNewlines)
                let mainCont = mainContent.components(separatedBy: "/* Begin PBXShellScriptBuildPhase section */")
                let xx = mainCont.last?.components(separatedBy: "};")
                
                if let px = xx?.first(where: {$0.contains(x!)}), px.contains(txtShellScript.stringValue), x!.count > 20 {
                    shouldAdd = false
                }
            }
        })
        return shouldAdd
    }
    
    //MARK: helps to get next id character
    func checkNextId(c: Character) -> Character {
        let tempId = Int(String(c))!
        let idChar = String(tempId + 1)
        return Character(idChar)
    }
    
    //MARK: get new id for every entry
    func getNewId(id: String) -> String {
        var idAllChars = Array(id)
        var newId = ""
        let char = idAllChars[7]
        dump(char)
        
        if char == "Z" {
            idAllChars[7] = "A"
            idAllChars[8] = checkNextId(c: idAllChars[8])
        } else {
            let asciiVal = char.asciiValue
            idAllChars[7] = Character(String(UnicodeScalar(UInt8(asciiVal! + 1))))
        }

        idAllChars.forEach({
            newId += String($0)
        })
        
        return newId
    }
    
    //MARK: add more button action
    @IBAction func btnAddMoreTextBox(_ sender: Any) {
        addAddNewTextField()
        btnReset.isEnabled = true
    }

    //MARK: reset button action
    @IBAction func btnResetAction(_ sender: Any) {
        clearAllStackView()
    }
    
    //MARK: add script button action
    @IBAction func btnAddScriptAction(_ sender: Any) {
        loadingView.isHidden = false
        loadingIndicator.isHidden = false
        readFileFromPath()
    }
    
    //MARK: adds new text field to input string
    func addAddNewTextField() {
        let textField = NSTextField()
        textField.placeholderString = "Enter input file string..."
        
        textField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        inputFilesStackView.addArrangedSubview(textField)
        setupStackviewHeight()
        
        if inputFilesStackView.arrangedSubviews.count > 0 {
            btnRemove.isEnabled = true
        }
    }
    
    //MARK: helps to clear stack view
    func clearAllStackView() {
        inputFilesStackView.arrangedSubviews.forEach({
            inputFilesStackView.removeArrangedSubview($0)
        })
        addAddNewTextField()
        txtShellScript.stringValue = ""
        txtRunScriptName.stringValue = ""
        scrollView.scroll(NSPoint(x: 0, y: 0))
        btnReset.isEnabled = false
        btnAddScript.isEnabled = false
        subviewFrame.size.height = CGFloat(inputFilesStackView.arrangedSubviews.count  * 38)
        gradient.frame = subviewFrame
        
        if inputFilesStackView.arrangedSubviews.count == 0 {
            btnRemove.isEnabled = false
        }
        
        lblProjecctLocationPath.stringValue = ""
        self.path = ""
        btnSelectProjectLocation.image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
    }
    
    //MARK: helps to remove text box added to input file string
    @IBAction func btnRemoveTextBoxAction(_ sender: Any) {
        if let latestTextView = inputFilesStackView.arrangedSubviews.last {
            inputFilesStackView.removeArrangedSubview(latestTextView)
            subviewFrame.size.height = CGFloat(inputFilesStackView.arrangedSubviews.count  * 38)
            gradient.frame = subviewFrame
        }
        if inputFilesStackView.arrangedSubviews.count == 0 {
            btnRemove.isEnabled = false
        }
    }
    
    //MARK: helps to setup stack view height
    func setupStackviewHeight(_ didRemove : Bool = false) {
        stackViewHeightConstraint.constant = CGFloat(inputFilesStackView.arrangedSubviews.count  * 38)
        
        if stackViewHeightConstraint.constant > self.scrollView.frame.height {
            scrollView.documentView?.frame.size.height += 30
        } else if stackViewHeightConstraint.constant > initialHeight && didRemove && scrollView.documentView?.frame.size.height ?? 0 > initialHeight  {
            scrollView.documentView?.frame.size.height -= 30
        }
        
        subviewFrame.size.height = CGFloat(inputFilesStackView.arrangedSubviews.count  * 38)
        gradient.frame = subviewFrame
    }
    
    //MARK: helps to open file explorer to let select your project
    @IBAction func btnSelectProjectLocationAction(_ sender: Any) {
        let dialog = NSOpenPanel()
        
        dialog.title                   = "Please select your project"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.allowsOtherFileTypes = true
//        dialog.allowedContentTypes = [.folder, .application, .appleArchive, .applicationBundle, .archive, .bundle, .package]
        
        if ( dialog.runModal() ==  NSApplication.ModalResponse.OK ) {
            var result = ""

            dialog.urls.forEach({
                result += $0.path() + ";"
            })
            
            result.removeLast()
            
            if !result.isEmpty {
                let path: String = result
                debugPrint(path)

               if let item = try? fileManager.contentsOfDirectory(atPath: path).first(where: {
                    $0.contains("xcodeproj")
               }) {
                   lblProjecctLocationPath.stringValue = path + item
                   btnSelectProjectLocation.image = NSImage(systemSymbolName: "folder.fill", accessibilityDescription: nil)
                   self.path = lblProjecctLocationPath.stringValue + "/project.pbxproj"
               } else {
                   
                   let alert = self.createAlert(title: "Oops", message: "Xcode project not found", okButtonTitle: "Ok", alertStyle: .warning)
                   
                   let modalResult = alert.runModal()
                   
                   switch modalResult {
                   case .alertFirstButtonReturn: // NSApplication.ModalResponse.alertFirstButtonReturn
                       print("First button clicked")
                   case .alertSecondButtonReturn:
                       print("Second button clicked")
                   case .alertThirdButtonReturn:
                       print("Third button clicked")
                   default:
                       print("Fourth button clicked")
                   }
                   
                   lblProjecctLocationPath.stringValue = ""
                   btnSelectProjectLocation.image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
                   self.path = ""
                   return
               }
            }
            btnReset.isEnabled = true
        } else {
            // User clicked on "Cancel"
            return
        }
        
    }
}

