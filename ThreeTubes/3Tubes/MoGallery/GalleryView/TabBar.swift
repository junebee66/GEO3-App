

import SwiftUI

struct TabBar: View {
   var body: some View {
      TabView {
         Home().tabItem {
            Image("IconHome")
            Text("Home")
         }
         .tag(1)
         GalleryContentView().tabItem {
            Image("IconCards")
            Text("Certificates")
         }
         .tag(2)
          GallerySettingsView().tabItem {
            Image("IconSettings")
            Text("Settings")
         }
         .tag(3)
      }
      .edgesIgnoringSafeArea(.top)
   }
}

#if DEBUG
struct TabBar_Previews: PreviewProvider {
   static var previews: some View {
      TabBar()
//         .environment(\.colorScheme, .dark)
   }
}
#endif
