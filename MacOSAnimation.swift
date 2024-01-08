//
//  ViewController.swift
//  MacOS Animation
//
//  Created by Nitin Bhatia on 01/08/23.
//

import Cocoa
import WebKit

let html = """
<html>
<body>
    <h1> Hello </h1>
</body>
</html>

"""

class ViewController: NSViewController, NSViewControllerPresentationAnimator {
    func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
        let bottomVC = fromViewController
        let topVC = viewController
        
        topVC.view.wantsLayer = true
        topVC.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        
        topVC.view.alphaValue = 0
        
        bottomVC.view.addSubview(topVC.view)
        
        var frame = NSRectToCGRect(bottomVC.view.frame)
        frame = CGRectInset(frame, 0, 0)
        topVC.view.setFrameSize(frame.size)
        topVC.view.setFrameOrigin(frame.origin)
        topVC.view.layer?.backgroundColor = NSColor.gray.cgColor
        
        NSAnimationContext.runAnimationGroup({context in
            context.duration = 0.5
            topVC.view.animator().alphaValue = 0.8
        })
        
        
    }
    
    func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
        let topVC = viewController
        
        topVC.view.wantsLayer = true
        topVC.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        
        NSAnimationContext.runAnimationGroup({context in
            context.duration = 0.5
            topVC.view.animator().alphaValue = 0
        },completionHandler: {
            topVC.view.removeFromSuperview()
        })
    }
    

    @IBOutlet weak var ww: WKWebView!
    @IBOutlet weak var customAnimationBox: NSBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  customAnimationBox.alphaValue = 0
      
        // Do any additional setup after loading the view.
        
//        let webView2 = WKWebView()
//        webView2.loadHTMLString(html, baseURL: nil)
//
//        webView2.frame = view.frame
//        view.addSubview(webView2)
        
        
        ww.load(URLRequest(url: URL(string: "https://www.apple.com")!))
        
        let url = URLRequest(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
        
        
        
        URLSession.shared.dataTask(with: url) {data, response, err in
            
            print(response)
            
        }.resume()
        
       // ww.loadHTMLString(html, baseURL: nil)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
       // runAnimation()
        //scaleAnimation()
        
        let x = try? FileManager.default.contents(atPath: "/Users/nitinbhatia/Desktop/app-debug.aab")
        print(x?.base64EncodedString())
        
        
//        ww.loadHTMLString(html, baseURL: nil)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
//            let vc = self.storyboard?.instantiateController(withIdentifier: "test") as! NSViewController
//            self.present(vc, animator: self)
//        })
    }
    
    private func scaleAnimation() {
        // Set the scale of the view to 2
        let doubleSize = NSSize(width: 2.0, height: 2.0)
       // customAnimationBox.scaleUnitSquare(to: doubleSize)
        
        // Create the scale animation
        let animation = CABasicAnimation()
        let duration = 1.0

        animation.duration = duration
        animation.fromValue = CATransform3DMakeScale(1.0, 1.0, 1.0)
        animation.toValue = CATransform3DMakeScale(2.0, 2.0, 1.0)

        // Trigger the scale animation
        customAnimationBox.layer?.add(animation, forKey: "transform")
        
        
        
        var origin = customAnimationBox.frame.origin
        // Add a simultaneous translation animation to keep the
        // view center static during the zoom animation
        
        NSAnimationContext.runAnimationGroup({ context in
            // Match the configuration of the scale animation
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(
                name: CAMediaTimingFunctionName.linear)

            // Translate the frame
            
            // Trigger the animation
            customAnimationBox.animator().frame.size = CGSize(width: 2, height: 2)
            customAnimationBox.animator().frame.origin = CGPoint(x: customAnimationBox.frame.origin.x - customAnimationBox.frame.width , y: customAnimationBox.frame.origin.y - customAnimationBox.frame.height)
        })
    }


    private func runAnimation() {
        NSAnimationContext.runAnimationGroup({ context in
            // 1 second animation
            context.duration = 3

            // The view will animate to alphaValue 0
            customAnimationBox.animator().alphaValue = 1
            
//            customAnimationBox.animator().cornerRadius = 50
//
//            var origin = customAnimationBox.frame.origin
//            origin.y -= 20
//
//                // The view will animate to the new origin
//            customAnimationBox.animator().frame.origin = origin
            
            
        }) {
            // Handle completion
        }
    }
}

