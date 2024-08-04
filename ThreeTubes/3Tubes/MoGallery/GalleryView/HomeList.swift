

import SwiftUI

struct HomeList: View {

   var yourModel = modelsData
   @State var showContent = false

   var body: some View {
      ScrollView {
         VStack {
            HStack {
               VStack(alignment: .leading) {
                  Text("YOUR MODELS")
                     .font(.largeTitle)
                     .fontWeight(.heavy)

                  Text("12 SPATIAL MOVIES")
                     .foregroundColor(.gray)
               }
               Spacer()
            }
            .padding(.leading, 50.0)

            ScrollView(.horizontal, showsIndicators: false) {
               HStack(spacing: 30.0) {
                  ForEach(yourModel) { item in
                     Button(action: { self.showContent.toggle() }) {
                        GeometryReader { geometry in
                            CourseView(title: item.title,
                                      image: item.image,
                                      color: item.color,
                                      shadowColor: item.shadowColor)
                              .rotation3DEffect(Angle(degrees:
                                 Double(geometry.frame(in: .global).minX - 30) / -40), axis: (x: 0, y: 10.0, z: 0))
//                              .sheet(isPresented: self.$showContent) { ContentView() }
                        }
                        .frame(width: 246, height: 660)
                     }
                  }
               }
//               .padding(.leading, 10)
               .padding(.top, 160)
//               .padding(.bottom, 70)
//               Spacer()
            }
//            CertificateRow()
         }
         .padding(.top, 18)
      }
   }
}

#if DEBUG
struct HomeList_Previews: PreviewProvider {
   static var previews: some View {
      HomeList()
   }
}
#endif

struct CourseView: View {

   var title = "Build an app with SwiftUI"
   var image = "Illustration1"
   var color = Color("purple")
//    var color = Color("background3")
   var shadowColor = Color("backgroundShadow3")

   var body: some View {
      return VStack(alignment: .leading) {
          
          ModelView()
              .frame(width: 346, height: 550)
          
          Text(title)
             .font(.title)
             .fontWeight(.bold)
             .foregroundColor(.white)
             .padding(30)
             .lineLimit(4)
      }
      .background(color)
      .cornerRadius(30)
      .frame(width: 446, height: 360)
      .shadow(color: shadowColor, radius: 20, x: 0, y: 20)
       
       
   }
}

struct Models: Identifiable {
   var id = UUID()
   var title: String
   var image: String
   var color: Color
   var shadowColor: Color
}

let modelsData = [
   Models(title: "The Final Presenation",
          image: "Illustration1",
          color: Color("background3"),
          shadowColor: Color("backgroundShadow3")),
   Models(title: "My Daughter and Her Friends",
          image: "Illustration2",
          color: Color("background4"),
          shadowColor: Color("backgroundShadow4")),
   Models(title: "My Cat",
          image: "Illustration3",
          color: Color("background7"),
          shadowColor: Color(hue: 0.677, saturation: 0.701, brightness: 0.788, opacity: 0.5)),
   Models(title: "Music Rehearsal",
          image: "Illustration4",
          color: Color("background8"),
          shadowColor: Color(hue: 0.677, saturation: 0.701, brightness: 0.788, opacity: 0.5)),
   Models(title: "Dancing Performace",
          image: "Illustration5",
          color: Color("background9"),
          shadowColor: Color(hue: 0.677, saturation: 0.701, brightness: 0.788, opacity: 0.5)),
]
