//
//  Verybasic.swift
//  MapKit Demo
//
//  Created by Tornike Despotashvili on 7/18/25.
//

import SwiftUI
import MapKit

struct Verybasic: View {
  @State private var camera: MapCameraPosition = .automatic
  let lisiLake = CLLocationCoordinate2D(latitude: 41.744397, longitude: 44.733402)
  
  let lakeBeach = CLLocationCoordinate2D(latitude: 41.74503857163819, longitude: 44.74114890180743)
  
  let zoo = CLLocationCoordinate2D(latitude: 41.713361, longitude: 44.780520)
  
  var body: some View {
    Map(position: $camera) {
      Marker("Lisi Lake", systemImage: "figure.open.water.swim", coordinate: lisiLake)
        .tint(.blue)
      
      Annotation("Lisi Lake", coordinate: lakeBeach) {
        Image("rubber")
          .resizable()
          .scaledToFit()
          .frame(width: 32, height: 32)
      }
    }
    .safeAreaInset(edge: .bottom) {
      HStack {
        Button {
          camera = .region(MKCoordinateRegion(center: zoo, latitudinalMeters: 300, longitudinalMeters: 300))
        } label: {
          Text("Center to Zoo")
        }
        .offset(y: 10)
      }
      .frame(maxWidth: .infinity)
      .background(.ultraThinMaterial)
    }
    //      .mapStyle(.hybrid)
    .mapStyle(.standard)
  }
}
