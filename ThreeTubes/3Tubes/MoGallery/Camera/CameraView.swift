/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct CameraView: View {
    
    @EnvironmentObject var photosModel: PhotosModel
    @EnvironmentObject var cameraModel: CameraModel
    @EnvironmentObject var app: AppModel

    private static let barHeightFactor = 0.15
    
    var body: some View {
        
        NavigationStack {
            GeometryReader { geometry in
                ViewfinderView(image:  $photosModel.viewfinderImage )
//                    .overlay(alignment: .top) {
//                        Color.black
//                            .opacity(0.75)
//                            .frame(height: geometry.size.height * Self.barHeightFactor)
//                    }
                    .overlay(alignment: .bottom) {
                        buttonsView()
                            .frame(height: geometry.size.height * Self.barHeightFactor)
                            .background(.black.opacity(0.75))
                    }
                    .overlay(alignment: .center)  {
                        Color.clear
                            .frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
                            .accessibilityElement()
                            .accessibilityLabel("View Finder")
                            .accessibilityAddTraits([.isImage])
                    }
                    .background(.black)
            }
//            .navigationTitle("Camera")
//            .navigationBarTitleDisplayMode(.inline)
        }        
    }
    
    private func buttonsView() -> some View {
        HStack(spacing: 30) {
            Spacer()
            Button {
                cameraModel.takePhoto()
            } label: {
                Label {
                    Text("Take Photo")
                } icon: {
                    ZStack {
                        Circle()
                            .strokeBorder(.white, lineWidth: 3)
                            .frame(width: 62, height: 62)
                        Circle()
                            .fill(.white)
                            .frame(width: 50, height: 50)
                    }
                }
            }
            Button {
                cameraModel.switchCaptureDevice()
            } label: {
                Label("Switch Camera", systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding()
    }
    
}
