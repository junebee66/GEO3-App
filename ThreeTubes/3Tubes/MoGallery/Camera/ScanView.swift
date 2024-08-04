import SwiftUI
import RealityKit
import ARKit

struct LabelScene: View {
    var onTapped: (() -> Void)? = nil

    var body: some View {
        Text("Scan")
            .font(.system(size: 65))
            .foregroundColor(.blue)
            .onTapGesture {
                onTapped?()
            }
    }
}

struct ScanView: View {
    enum ScanMode {
        case noneed
        case doing
        case done
    }

    @State private var scanMode: ScanMode = .noneed
    @State private var originalSource: Any? = nil

    var body: some View {
        ARViewContainer(scanMode: $scanMode, originalSource: $originalSource)
            .overlay(LabelScene {
                rotateMode()
            })
    }

    func rotateMode() {
        switch self.scanMode {
        case .noneed:
            self.scanMode = .doing
            originalSource = UIColor.black
        case .doing:
            break
        case .done:
            self.scanMode = .noneed
            originalSource = nil
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var scanMode: ScanView.ScanMode
    @Binding var originalSource: Any?

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        sceneView.delegate = context.coordinator
        sceneView.session.delegate = context.coordinator
        setARViewOptions(sceneView: sceneView)
        let configuration = buildConfigure()
        sceneView.session.run(configuration)
        setControls(sceneView: sceneView)
        return sceneView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Update the view
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        var parent: ARViewContainer

        init(parent: ARViewContainer) {
            self.parent = parent
        }

        // Implement ARSCNViewDelegate and ARSessionDelegate methods here
    }

    func setARViewOptions(sceneView: ARSCNView) {
        sceneView.scene = SCNScene()
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

    func setControls(sceneView: ARSCNView) {
        sceneView.overlaySKScene = SKScene(size: sceneView.bounds.size)
    }
}

//struct ContentView: View {
//    var body: some View {
//        ScanView()
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
