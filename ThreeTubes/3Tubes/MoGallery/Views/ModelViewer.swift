import SwiftUI
import SceneKit


struct ModelView: View {
    @EnvironmentObject var app: AppModel
    @State private var currentTexture = "texture.png" // Initial texture
    @State private var promptText = "beautiful landscape"
    @State private var heightText = "360"
    @State private var widthText = "480"
    @State private var isLoading = false
    @State private var image: UIImage?
    @State private var showDownloadButton = false
    
    var body: some View {
        VStack {
            ModelViewBridge(appURL: app.modelURL, currentTexture: $currentTexture)
            
            HStack {
                TextField("New Texture", text: $promptText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            HStack {
                Button(action: generateImage) {
                    Text("Generate Image")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
//                Button(action: ModelViewBridge.updateUIView) {
//                    Text("Update Texture")
//                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            if isLoading {
                ProgressView("Loading...")
            }
            
            if image != nil {
                Image(uiImage: image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 200)
                    .padding()
            }
        }
    }
    
    func generateImage() {
        isLoading = true
        showDownloadButton = false
        image = nil
        
        let description = promptText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "beautiful%20landscape"
        let randomSeed = Int.random(in: 0..<1000000000)
        let heightA = Int(heightText) ?? 360
        let widthA = Int(widthText) ?? 480
        
        let imageUrl = "https://image.pollinations.ai/prompt/\(description)?nologo=1&seed=\(randomSeed)&height=\(heightA)&width=\(widthA)"
        print("URL: \(imageUrl)")
        
        if let url = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        isLoading = false
                        image = uiImage
                        showDownloadButton = true
                        
                        // Convert UIImage to Data as a JPEG image
                        if let imageData = uiImage.jpegData(compressionQuality: 1.0) {
                            // Define a filename for the generated image (e.g., "generatedImage.jpg")
                            let filename = "generatedImage.jpg"
                            
                            // Save the generated image to the app's Documents directory
                            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                                let fileURL = documentsDirectory.appendingPathComponent(filename)
                                
                                do {
                                    try imageData.write(to: fileURL)
                                    currentTexture = filename // Update currentTexture with the filename
                                } catch {
                                    print("Error saving image: \(error)")
                                }
                            }
                        }
                    }
                }
            }.resume()
        }
    }
}

struct ModelView_Previews: PreviewProvider {
    static var previews: some View {
        ModelView()
    }
}

struct ModelViewBridge: UIViewRepresentable {
    var appURL: URL?
    @Binding var currentTexture: String
//    var matFile:
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        
//        var scene: SCNScene?
        // Load .obj file
//        var scene = SCNScene(named: "air_jordan_1_retro_high_tie_dye.usdz")

        let scene = SCNScene(named: "headShake.usdz")

        print("obj created", appURL ?? "no value")
        
//            if appURL != nil{
//                do {
//                    scene = try SCNScene(url: appURL!, options: nil);
//                    print("obj updated")
//                } catch {print("error", error)}
//            }
        
//        if app.modelURL != nil{
//            do {
//                scene = try SCNScene(url: app.modelURL!, options: nil);
//                print("obj updated")
//            } catch {print("error", error)}
//        }

        
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
        sceneView.backgroundColor = UIColor.black
        
        // Allow user translate image
        sceneView.cameraControlConfiguration.allowsTranslation = false
        
        // Set scene settings
        sceneView.scene = scene
        
        return sceneView
    }
    
//    func updateUIView(_ uiView: SCNView, context: Context) {
//        var scene:SCNScene?
//       print("update UI View", appURL ?? "no value")
//        if appURL != nil{
//            do {
//                let objMaterial = SCNMaterial()
//                objMaterial.diffuse.contents = UIImage(named: "texture.png")
//
//                scene = try SCNScene(url: appURL!, options: nil);
//                print("this is SCNscene", scene)
////                scene.materials = [objMaterial]
//                uiView.scene = scene
//                print("obj updated")
//            } catch {print("error", error)}
//        }
//    }
    
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        var scene: SCNScene?
        print("update UI View", appURL ?? "no value")
        
        if let appURL = appURL {
            do {

                scene = try SCNScene(url: appURL, options: nil)
                
                let shoe = SCNScene(named: "air_jordan_1_retro_high_tie_dye.usdz")
                
                let dScene = SCNScene(named: "originalScene.usdz")


                // Assuming you want to apply the material to all geometries in the scene


                
                let sphereGeometry = SCNSphere(radius: 1.0) // Adjust the radius as needed
                let sphereMaterial = SCNMaterial()
                            sphereMaterial.diffuse.contents = UIImage(named: currentTexture)
//                            sphereGeometry.materials = [sphereMaterial]

                
                let sphereNode = SCNNode(geometry: sphereGeometry)
//                scene?.rootNode.addChildNode(sphereNode)
//                dScene?.rootNode.addChildNode(sphereNode)

                
                let objMaterial = SCNMaterial()
                objMaterial.diffuse.contents = UIImage(named: currentTexture)
                objMaterial.isDoubleSided = true
                
//                scene?.rootNode.childNodes.forEach { node in
//                    if let geometry = node.geometry {
//                        for mdlMaterial in geometry.materials {
//                            // Apply your material settings here
//                            mdlMaterial.diffuse.contents = UIImage(named: "texture.png")
//                            mdlMaterial.lightingModel = .physicallyBased
//                            mdlMaterial.isLitPerPixel = true
//                            mdlMaterial.diffuse.contents = UIImage(named: "texture.png")
//                            mdlMaterial.roughness.contents = UIImage(named: "texture.png")
//                        }
//                    }
//                }

//                scene?.rootNode.childNodes.forEach { node in
//                    applyMaterialToGeometries(node, material: objMaterial)
//                }

                dScene?.rootNode.childNodes.forEach { node in
                    applyMaterialToGeometries(node, material: objMaterial)
                }

                uiView.scene = dScene
                print("obj updated")
            } catch {
                print("error", error)
            }
        }
    }

}

func applyMaterialToGeometries(_ node: SCNNode?, material: SCNMaterial) {
    guard let node = node else { return }
    
    if let geometry = node.geometry {
        // Print the geometry type to debug
        print("Geometry Type:", type(of: geometry))
        
        // Set the material to the geometry
        geometry.materials = [material]
    }


    node.childNodes.forEach {
        applyMaterialToGeometries($0, material: material)
    }
}

