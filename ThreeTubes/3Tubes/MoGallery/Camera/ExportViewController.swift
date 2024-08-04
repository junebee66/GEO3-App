//
//  ContentView.swift
//  ARStarter
//
//

import SwiftUI
import RealityKit
import ARKit

class Model : ObservableObject {
    var arView:ARView?
}

struct ExportView : View {
    @StateObject var model = Model();
    @EnvironmentObject var app: AppModel;
    
    var body: some View {
        ZStack {
            ARViewContainerExport(model: model)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Button(action: {
                    print("Export Action model.arView", model.arView ?? "-none-")
                    guard let arView = model.arView else { return }
                    do {
                        let url = try exportArView(arView, fileName: "arexport.obj")
                        app.modelURL = url
                        
                        
                        print("Export Action url", url)
                    } catch {
                        print("exportArView error", error)
                    }
                }) {
                    Text("Export")
                }
            }
        }
    }
}

struct ARViewContainerExport: UIViewRepresentable {
    var model:Model
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        // !!@ delegate not used
        // arView.session.delegate = self
        initARView(arView)
        model.arView = arView
        return arView
    }
    func updateUIView(_ uiView: ARView, context: Context) {
        print("ARViewContainerExport updateUIView")
    }
}

// _course-repos/07-PhotoPickBlender/PhotoPickBlender.xcodeproj

// _homework/09-June-Bee-junebee66/Week06/JuneLiDAR/JuneLiDAR.xcodeproj
//      ExportViewController
//
func initARView(_ arView: ARView) {
    func setARViewOptions() {
        arView.debugOptions.insert(.showSceneUnderstanding)
    }
    func buildConfigure() -> ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.environmentTexturing = .automatic
        configuration.sceneReconstruction = .mesh
        if type(of: configuration).supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics = .sceneDepth
        }
        return configuration
    }
    setARViewOptions()
    let configuration = buildConfigure()
    arView.session.run(configuration)
}

func exportArView(_ arView: ARView, fileName: String) throws -> URL {
    guard let camera = arView.session.currentFrame?.camera else {
        throw ExportError.noCamera
    }
    
    func convertToAsset(meshAnchors: [ARMeshAnchor]) -> MDLAsset? {
        @EnvironmentObject var app: AppModel;
        
        guard let device = MTLCreateSystemDefaultDevice() else {return nil}
        let asset = MDLAsset()
        for anchor in meshAnchors {
            let mdlMesh = anchor.geometry.toMDLMesh(device: device, camera: camera, modelMatrix: anchor.transform)
            asset.add(mdlMesh)
//            app.mtlFile = asset
            
        }
        return asset
    }
    //export to obj
    func export(asset: MDLAsset) throws -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = directory.appendingPathComponent(fileName)
        try asset.export(to: url)
        return url
    }
    func share(url: URL) {
//        let vc = UIActivityViewController(activityItems: [url],applicationActivities: nil)
//        vc.popoverPresentationController?.sourceView = sender
//        self.present(vc, animated: true, completion: nil)
    }
    if let meshAnchors = arView.session.currentFrame?.anchors.compactMap({ $0 as? ARMeshAnchor }),
       let asset = convertToAsset(meshAnchors: meshAnchors) {
        return try export(asset: asset)
//        do {
//            let url = try export(asset: asset)
//            share(url: url)
//        } catch {
//            print("exportArView error", error)
//        }
    }
    throw ExportError.noURL;
}

enum ExportError: Error {
    case noCamera
    case noURL
}

//struct ARViewContainerInitial: UIViewRepresentable {
//    func makeUIView(context: Context) -> ARView {
//        let arView = ARView(frame: .zero)
//        // Create a cube model
//        // let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
//        // let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
//        let mesh = MeshResource.generateBox(size: 0.2, cornerRadius: 0.005)
//        let material = SimpleMaterial(color: .red, roughness: 0.15, isMetallic: false)
//        let model = ModelEntity(mesh: mesh, materials: [material])
//        // Create horizontal plane anchor for the content
//        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
//        anchor.children.append(model)
//        // Add the horizontal plane anchor to the scene
//        arView.scene.anchors.append(anchor)
//        return arView
//    }
//    func updateUIView(_ uiView: ARView, context: Context) {}
//}

//#Preview {
//    ContentView()
//}
