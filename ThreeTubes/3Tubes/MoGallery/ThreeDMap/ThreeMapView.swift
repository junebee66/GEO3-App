/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view that hosts an `MKMapView`.
*/

import SwiftUI
import MapKit

extension CLLocationCoordinate2D{
    static let parking = CLLocationCoordinate2D(latitude: 40.6929116, longitude: -73.9874613)
}

struct ThreeMapView: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
//        MKMapView(frame: .zero)
        let map = MKMapView(frame: .zero)
        map.isPitchEnabled = true
        map.showsBuildings = true
//        map.mapType = .hybridFlyover

        
        let mapCamera = MKMapCamera()
        mapCamera.pitch = 60
        mapCamera.altitude = 100 // example altitude
        mapCamera.heading = 180
        

        
        map.camera = mapCamera
        return map
    }

    func updateUIView(_ view: MKMapView, context: Context) {
//        let coordinate = CLLocationCoordinate2D(
//            latitude: 40.6929116, longitude: -73.9874613)

        
        let eiffelTowerCoordinates = CLLocationCoordinate2DMake(40.6929116, -73.9874613)
        
//        let span = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
//        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        let region = MKCoordinateRegion(center: eiffelTowerCoordinates, latitudinalMeters: 1000, longitudinalMeters: 100)
//        view.setRegion(region, animated: true)
        
        let parkingAnnotation = MKPointAnnotation()
                parkingAnnotation.title = "June"
                parkingAnnotation.coordinate = .parking
                view.addAnnotation(parkingAnnotation)
                
                // Adding the custom Map code
                view.addOverlay(MKCircle(center: .parking, radius: 50), level: .aboveLabels)
                view.camera = MKMapCamera(lookingAtCenter: .parking, fromEyeCoordinate: .parking, eyeAltitude: 300)
            }
}

#if DEBUG
struct ThreeMapView_Previews: PreviewProvider {
    static var previews: some View {
        ThreeMapView()
    }
}
#endif
