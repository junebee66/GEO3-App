/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI
import Photos

// load image async from cache with specified size imageSize
// display progress while loading with ProgressView

struct PhotoItemView: View {
    var asset: PhotoAsset
    var cache: CachedImageManager?
    var imageSize: CGSize
    
    @State private var image: Image?
    @State private var imageRequestID: PHImageRequestID?

    var body: some View {
        
        Group {
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView()
                    .scaleEffect(0.5)
            }
        }
        .task {
            guard image == nil, let cache = cache else { return }
            imageRequestID = await cache.requestImage(for: asset, targetSize: imageSize) { result in
                Task {
                    if let result = result {
                        self.image = result.image
                    }
                }
            }
        }
    }
}
