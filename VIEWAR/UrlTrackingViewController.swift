//
//  UrlTrackingControllerViewController.swift
//  VIEWAR
//
//  Created by Thanphicha Yimlamai on 28/12/2565 BE.
//

import UIKit
import ARKit
import WebKit


class UrlTrackingViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    //var webView : WKWebView!
    //var store : String!
    let updateQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).serialSCNQueue")
    
    @IBAction func backButton(_ sender: Any) {
        self.back()
    }
    func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARImageTrackingConfiguration()
        guard let trackingImage = ARReferenceImage.referenceImages(inGroupNamed: "moshi", bundle: Bundle.main) else {
            fatalError("Couldn't track images.")
        }
        configuration.trackingImages = trackingImage
        configuration.maximumNumberOfTrackedImages = 1
        sceneView.session.run(configuration, options: ARSession.RunOptions(arrayLiteral: [.resetTracking, .removeExistingAnchors]))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
}

extension UrlTrackingViewController : ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else {return}
        
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        
        plane.firstMaterial?.colorBufferWriteMask = .alpha
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2
        planeNode.renderingOrder = -1
        planeNode.opacity = 1
        
        node.addChildNode(planeNode)
        
        self.highlightDetection(on: planeNode, width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height, completionHandler: {
            
            self.urlView(on: planeNode, xOffset: imageAnchor.referenceImage.physicalSize.width)
            
        })
    }
    
    func urlView(on rootNode: SCNNode, xOffset: CGFloat) {
        DispatchQueue.main.async {
           
            let webConfiguration = WKWebViewConfiguration()
            let request = URLRequest(url: URL(string: "https://mimiichannal.maggang.com/แนะนำของน่าซื้อ-10-อย่าง-ในร้าน-moshi-moshi-โมชิ-โมชิ")!)
            let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 400, height: 670), configuration: webConfiguration)
            webView.load(request)

            let webViewPlane = SCNPlane(width: xOffset, height: xOffset * 1.4)
            webViewPlane.cornerRadius = 0.20

            let webViewNode = SCNNode(geometry: webViewPlane)

            // Set the web view as webViewPlane's primary texture
            webViewNode.geometry?.firstMaterial?.diffuse.contents = webView
            webViewNode.position.z -= 0.5
            webViewNode.opacity = 0

            rootNode.addChildNode(webViewNode)
            webViewNode.runAction(.sequence([
                .wait(duration: 3.0),
                .fadeOpacity(to: 1.0, duration: 1.5),
                .moveBy(x: xOffset * 1.1, y: 0, z: -0.05, duration: 1.5),
                .moveBy(x: 0, y: 0, z: -0.05, duration: 0.2)
                ])
            )
        }
    }
    
    func highlightDetection(on rootNode: SCNNode, width: CGFloat, height: CGFloat, completionHandler block: @escaping (() -> Void)) {
        let planeNode = SCNNode(geometry: SCNPlane(width: width, height: height))
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.cyan
        planeNode.position.z += 0.1
        planeNode.opacity = 0
        
        rootNode.addChildNode(planeNode)
        planeNode.runAction(self.imageHighlightAction) {
            block()
        }
    }
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 0.5),
            .removeFromParentNode()
            ])
    }
}


