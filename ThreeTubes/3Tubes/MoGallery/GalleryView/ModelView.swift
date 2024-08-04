//
//  ContentView.swift
//  3dview
//
//  Created by June Bee on 11/30/23.
//

import SwiftUI

import SceneKit

//struct ContentView: View {
//    var body: some View {
//        SceneKitView()
//            .edgesIgnoringSafeArea(.all)
//    }
//}

struct GalleryModelView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        
        // Load .obj file
        let scene = SCNScene(named: "20231107sptial_video.usdz")
//        let scene = SCNScene(named: "air_jordan_1_retro_high_tie_dye.usdz")

        // Add camera node
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // Place camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 75)
        
        // Set camera on scene
        scene?.rootNode.addChildNode(cameraNode)
        
        // Adding light to scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 35)
        scene?.rootNode.addChildNode(lightNode)
        
        // Creating and adding ambient light to scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene?.rootNode.addChildNode(ambientLightNode)
        
        // If you don't want to fix manually the lights
        // sceneView.autoenablesDefaultLighting = true
        
        // Allow user to manipulate camera
        sceneView.allowsCameraControl = true
        
        // Set background color
        sceneView.backgroundColor = UIColor.clear
        
        // Allow user translate image
        sceneView.cameraControlConfiguration.allowsTranslation = false
        
        // Set scene settings
        sceneView.scene = scene
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update the view if needed
    }
}


struct GalleryModelView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryModelView()
    }
}
