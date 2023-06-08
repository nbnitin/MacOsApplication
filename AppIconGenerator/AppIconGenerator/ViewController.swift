//
//  ViewController.swift
//  AppIconGenerator
//
//  Created by Nitin Bhatia on 07/06/23.
//

import Cocoa
import UniformTypeIdentifiers

let IOS_ICON_IMAGES = ["40x40","60x60","58x58","87x87","76x76","114x114","80x80","120x120",
                       "180x180", "128x128", "192x192", "136x136", "152x152", "167x167"]

let ANDROID_ICON_IMAGES : [[String:String]] = [["mipmap-hdpi":"72x72"],["mipmap-mdpi":"48x48"],["mipmap-xhdpi":"96x96"],["mipmap-xxhdpi":"144x144"],["mipmap-xxxhdpi":"192x192"]]

enum SAVE_IMAGE_TYPE {
    case JPG
    case PNG
}

class ViewController: NSViewController {

    @IBOutlet weak var btnSelectDropLocation: NSButton!
    @IBOutlet weak var btnGenerateIcons: NSButton!
    @IBOutlet weak var lblSelectDropLocation: NSTextField!
    @IBOutlet weak var btnOpenPath: NSButton!
    @IBOutlet weak var lblOpenPath: NSTextField!
    
    var originalImage : NSImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnGenerateIcons.isEnabled = false
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    //MARK: - opens dialog to let user select image path
    @IBAction func btnOpenPathAction(_ sender: Any) {
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Please image"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        
        
            dialog.canChooseFiles = true
            dialog.canChooseDirectories = false
            dialog.allowsMultipleSelection = false
            dialog.allowsOtherFileTypes = true
        dialog.allowedContentTypes = [.jpeg,.png]
        
        
        
        if ( dialog.runModal() ==  NSApplication.ModalResponse.OK ) {
            var result = ""
            
           
            
            dialog.urls.forEach({
                result += $0.path() + ";"
            })
            
            result.removeLast()
            
            if !result.isEmpty {
                let path: String = result
                debugPrint(path)
                
                if isImageValid(url: path) {
                    btnGenerateIcons.isEnabled = lblSelectDropLocation.stringValue == "" ? false : true
                    lblOpenPath.stringValue = path
                    btnOpenPath.image = NSImage(systemSymbolName: "folder.fill", accessibilityDescription: nil)
                } else {
                    btnGenerateIcons.isEnabled = false
                    lblOpenPath.stringValue = ""
                    btnOpenPath.image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
                    let modal = createAlert(title: "Oops", message: "Not a valid image 1024", okButtonTitle: "Ok", alertStyle: .warning)
                    modal.runModal()
                }
                
            }
           
        } else {
            // User clicked on "Cancel"
            return
        }
        
    }
    
    //MARK: - check for image validation is equal to 1204 size or not
    private func isImageValid(url: String) -> Bool {
        if let image = NSImage(contentsOf: URL(fileURLWithPath: url.replacingOccurrences(of: "%20", with: " "))) {
            
            if image.size == CGSize(width: 1024, height: 1024) {
                originalImage = image
                return true
            }
            return false
        }
        
        return false
            
    }
    
    //MARK: - opens dialog to let user select path where to save
    @IBAction func btnSelectDropLocationAction(_ sender: Any) {
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Please select drop location"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false

        if ( dialog.runModal() ==  NSApplication.ModalResponse.OK ) {
            var result = ""
            
           
            
            dialog.urls.forEach({
                result += $0.path() + ";"
            })
            
            result.removeLast()
            
            if !result.isEmpty {
                let path: String = result
                debugPrint(path)
                
                if lblOpenPath.stringValue != "" {
                    lblSelectDropLocation.stringValue = path
                    btnGenerateIcons.isEnabled = true
                    btnSelectDropLocation.image = NSImage(systemSymbolName: "folder.fill", accessibilityDescription: nil)
                } else {
                    btnGenerateIcons.isEnabled = false
                    btnSelectDropLocation.image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
                }
                
            }
           
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    //MARK: - button action to create all resources
    @IBAction func btnGenerateIconsAction(_ sender: Any) {
        do {
            try FileManager.default.createDirectory(atPath: lblSelectDropLocation.stringValue + "res/iOS/", withIntermediateDirectories: true)
            try FileManager.default.createDirectory(atPath: lblSelectDropLocation.stringValue + "res/android/", withIntermediateDirectories: true)
        } catch(let err) {
            print(err.localizedDescription)
        }
        
        for items in IOS_ICON_IMAGES {
            let frame = items.components(separatedBy: "x")
            let width = Int(frame.first ?? "0")
            let height = Int(frame.last ?? "0")
            let targetSize = CGSize(width: width!, height: height!)
            let resizedImage = generateImage(size: targetSize)
            saveImage(in: .JPG, at: lblSelectDropLocation.stringValue + "res/iOS/icons \(items).jpg", image: resizedImage)
        }
        
        for items in ANDROID_ICON_IMAGES {
            let path = (items.keys.first ?? "")
            try? FileManager.default.createDirectory(atPath: lblSelectDropLocation.stringValue + "res/android/\(path)", withIntermediateDirectories: true)
            let frame = items[path]!.components(separatedBy: "x")
            let width = Int(frame.first ?? "0")
            let height = Int(frame.last ?? "0")
            let targetSize = CGSize(width: width!, height: height!)
            let circleImage = generateRoundedIcons(size: targetSize, isCircle: true)
            let roundedCornerImage = generateRoundedIcons(size: targetSize, isCircle: false)
            saveImage(in: .PNG, at: lblSelectDropLocation.stringValue + "res/android/\(path)/ic_launcher_rounded.png", image: circleImage)
            saveImage(in: .PNG, at: lblSelectDropLocation.stringValue + "res/android/\(path)/ic_launcher.png", image: roundedCornerImage)
        }
        
        try? FileManager.default.copyItem(atPath: lblOpenPath.stringValue, toPath: lblSelectDropLocation.stringValue+"res/"+"1024.jpg")
        
        let modal = createAlert(title: "Success", message: "Resource folder created...", okButtonTitle: "Ok", alertStyle: .informational)
        modal.runModal()
        clearAll()
    }
    
    //MARK: - helps to generate images of given size
    private func generateImage(size: NSSize) -> NSImage {
        let newSize = NSSize(width: size.width / 2, height: size.height / 2)
        let resizedImage = NSImage(size: newSize)
        resizedImage.lockFocus()
        originalImage.draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), from: NSRect(x: 0, y: 0, width: originalImage.size.width, height: originalImage.size.height), operation: .copy, fraction: CGFloat(1.0))
        resizedImage.unlockFocus()
        return resizedImage
    }
    
    //MARK: - helps to save image at given location
    private func saveImage(in format: SAVE_IMAGE_TYPE, at url: String, image: NSImage) {
        switch format {
        case .JPG:
            try? convertImageToData(in: format, image: image).write(to: URL(filePath: url))
        case .PNG:
            try? convertImageToData(in: format, image: image).write(to: URL(filePath: url))
        }
    }
    
    //MARK: - convert image to data
   private func convertImageToData(in format: SAVE_IMAGE_TYPE, image: NSImage) -> Data {
        switch format {
        case .JPG:
            let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
            let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
            let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
            return jpegData
        case .PNG:
            let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
            let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
            let pngData = bitmapRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:])!
            return pngData
        }
    }
    
    //MARK: - helps to create rounded icons, mainly used for android
    private func generateRoundedIcons(size: NSSize, isCircle: Bool = false) -> NSImage {
        let newSize = NSSize(width: size.width / 2, height: size.height / 2)
        let resizedImage = NSImage(size: newSize)
        resizedImage.lockFocus()
        
        var radius : CGFloat = 0.0
        
        if isCircle {
            radius = newSize.width / 2
        } else {
            radius = (size.width * 8.33) / 100 //this was mention somewhere on google android app icon guidelines it should radius should be 8.33% of image size and image should be perfect square height and width must be equal
        }
        
        let path = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), xRadius: radius, yRadius: radius)
        path.addClip()
        originalImage.draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        resizedImage.unlockFocus()
        
        return resizedImage
    }
    
    private func clearAll() {
        lblOpenPath.stringValue = ""
        lblSelectDropLocation.stringValue = ""
        btnOpenPath.image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
        btnSelectDropLocation.image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
        btnGenerateIcons.isEnabled = false
    }
    
}

