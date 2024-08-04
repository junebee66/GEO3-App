

import SwiftUI
import MapKit

//let locationFont = Font
//    .system(size: 20)
//    .monospaced()
//
//let delta = 0.001

struct MapView: View {
    // !!@ fails with crash when passing
//    @StateObject var mapRegion: MapRegionModel
//    @StateObject var lobbyModel: LobbyModel
//    @EnvironmentObject var app: AppModel

    var locs: [Location]
    
    // !!@ Would like use mapRegion, but fails
    // Get warnings, but at least we don't crash
//    !!@ Modifying state during view update, this will cause undefined behavior.
//    !!@ Publishing changes from within view updates is not allowed, this will cause undefined behavior.

    @State var locIndex = 0
    @State var regionLabel = ""
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334_900,
                                       longitude: -122.009_020),
        latitudinalMeters: 750,
        longitudinalMeters: 750
    )

    var body: some View {
        ZStack {
            //  Map(coordinateRegion: locationManager.region,
            //  Map(coordinateRegion: $locationManager.region,
            //  Map(coordinateRegion: $region,
            //      annotationItems: lobbyModel.mapRegion.locs )
            Map(coordinateRegion: $region,
                annotationItems: locs )
            { location in
                // MapMarker(coordinate: location.coordinate)
                MapAnnotation(coordinate: location.coordinate) {
                    VStack {
                        Image(systemName: "star.circle")
                            .resizable()
                            .foregroundColor(.red)
                            .frame(width: 44, height: 44)
                            .background(.white)
                            .clipShape(Circle())
                        Text(location.label)
                    }
                }
            }
            // .ignoresSafeArea()
            Circle()
                .fill(.blue)
                .opacity(0.3)
                .frame(width: 32, height: 32)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: centerUserLocationAction ) {
                        Image(systemName: "star")
                    }
                    .padding()
                    .background(.black.opacity(0.75))
                    .foregroundColor(.white)
                    .font(.title)
                    .clipShape(Circle())
                }
            }
            VStack {
                Spacer()
                Text("lat: \(centerLatitude)")
                    .font(locationFont)
                Text("lon: \(centerLongitude)")
                    .font(locationFont)
                Text(regionLabel)
                    .font(locationFont)
            }
        }
        .onAppear {
            print("MapView onAppear locs", locs)
            setRegionMain(0);
        }
    }
    
    func setRegionMain (_ offset: Int) {
        print("MapView setRegionMain offset", offset)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            setRegionState(offset)
        }
    }
    
    func setRegionState(_ offset: Int) {
        print("MapView setRegionState offset", offset)
        if locIndex >= locs.count || locs.count < 1 { return }
        locIndex = (locIndex + offset ) % locs.count
        let loc = locs[locIndex]
        regionLabel = loc.label
        region = MKCoordinateRegion(center: loc.coordinate, span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
        print("MapView setRegionState offset", offset, "loc", loc, "locIndex", locIndex)
    }
    
    var centerLatitude: String {
        String(format: "%+.6f", region.center.latitude)
    }
    
    var centerLongitude: String {
        String(format: "%+.6f", region.center.longitude)
    }

    func centerUserLocationAction() {
        withAnimation {
            print("centerUserLocationAction locIndex", locIndex, "locs.count", locs.count)
            setRegionMain(1)
        }
    }
}

//struct Location: Identifiable, Codable, Equatable {
//    var id: String
//    let latitude: Double
//    let longitude: Double
//    let label: String
//    var coordinate: CLLocationCoordinate2D {
//        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//    }
//}

