//
//  ViewController.swift
//  VIEWAR
//
//  Created by Thanphicha Yimlamai on 28/10/2565 BE.
//

import UIKit
import ARKit
class DrawingViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
               // self.sceneView.showsStatistics = true
               self.sceneView.session.run(configuration)
               self.sceneView.delegate = self

        
        drawButton.layer.cornerRadius = drawButton.frame.size.width/2
        uploadButton.layer.cornerRadius = uploadButton.frame.size.width/2
        // Do any additional setup after loading the view.
    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentPositionOfCamera = orientation + location
        DispatchQueue.main.async {
            if self.drawButton.isHighlighted{
                let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.01))
                sphereNode.position = currentPositionOfCamera
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
                print("The button is being pressed")
            }
            else{
                let pencil = SCNNode(geometry: SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0.01/2))
                pencil.position = currentPositionOfCamera
                self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
                    if node.geometry is SCNBox{
                        node.removeFromParentNode()
                    }
                })
                self.sceneView.scene.rootNode.addChildNode(pencil)
                pencil.geometry?.firstMaterial?.diffuse.contents = UIColor.green
            }
        }
    }
    
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3{
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    
}

