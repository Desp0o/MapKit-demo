//
//  PlaceDetails.swift
//  MapKit Demo
//
//  Created by Tornike Despotashvili on 7/21/25.
//

import SwiftUI
import MapKit

struct PlaceDetails: View {
  @Binding var mapSelection: MKMapItem?
  @Binding var lookAround: MKLookAroundScene?
  @Binding var getDirection: Bool
  let getRoute: () -> Void
  
  var body: some View {
    VStack(alignment: .leading) {
      if let place = mapSelection {
        Text("\(place.placemark.title ?? "")")
        Text("\(place.placemark.subtitle ?? "")")
      }
      
      if let scene = lookAround {
        LookAroundPreview(initialScene: scene, allowsNavigation: true, showsRoadLabels: true)
          .frame(height: 250)
          .clipShape(RoundedRectangle(cornerRadius: 12))
      } else {
        ContentUnavailableView("No Preview", systemImage: "eye.slash")
      }
      
      HStack {
        Button {
          mapSelection?.openInMaps()
        } label: {
          Text("Open in maps")
        }
        .buttonStyle(.bordered)
        
        Spacer()
        
        Button {
          getRoute()
        } label: {
          Text("Get Direction")
        }
        .buttonStyle(.borderedProminent)
      }
    }
    .padding()
    .presentationDetents([.medium])
  }
}
