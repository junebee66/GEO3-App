
import SwiftUI

struct ThreeDMapView: View {
    var body: some View {
        VStack {
            ThreeMapView()
                .edgesIgnoringSafeArea(.top)
                .frame(height: 1000)
            
            MapModelView()
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
                .offset(x: 0, y: -430)
                .padding(.bottom, -130)
                .frame(height: 150)

//            CircleImage()
//                .offset(x: 0, y: -130)
//                .padding(.bottom, -130)

//                VStack(alignment: .leading) {
//                Text("Movie Title")
//                    .font(.title)
//                HStack(alignment: .top) {
//                    Text("2023/3/24")
//                        .font(.subheadline)
//                    Spacer()
//                    Text("California")
//                        .font(.subheadline)
//                }.padding(.bottom, 0)
//            }
//            .padding()

            Spacer()
        }
    }
}

#if DEBUG
struct ThreeDMapView_Previews: PreviewProvider {
    static var previews: some View {
        ThreeDMapView()
    }
}
#endif
