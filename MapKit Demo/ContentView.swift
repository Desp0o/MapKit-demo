//
//  ContentView.swift
//  MapKit Demo
//
//  Created by Tornike Despotashvili on 7/18/25.
//

import SwiftUI
import MapKit
import IzziLocationKit

struct ContentView: View {
  @State private var locationManager = IzziLocationKit()
  @State private var camera: MapCameraPosition = .automatic
  @State private var query: String = ""
  @State private var mapSelection: MKMapItem?
  @State private var searchResults: [MKMapItem] = []
  @State private var showPlaceDetails: Bool = false
  @State private var lookAround: MKLookAroundScene?
  
  @State private var getDirections: Bool = false
  @State private var routeDisplaying: Bool = false
  @State private var route: MKRoute?
  @State private var routeDestination: MKMapItem?
  
  var body: some View {
    if let coordinates = locationManager.currentCoordinates {
      Map(position: $camera, selection: $mapSelection) {
        UserAnnotation()
        
        ForEach(searchResults, id: \.self) { item in
          let place = item.placemark
          Marker(place.title ?? "", coordinate: place.coordinate)
        }
        
        if let route {
          MapPolyline(route.polyline)
            .stroke(.blue, lineWidth: 8)
        }
      }
      .mapControlVisibility(.visible)
      .mapControls {
        MapCompass()
        MapUserLocationButton()
        MapPitchToggle()
      }
      .onAppear {
        camera = .region(MKCoordinateRegion(center: coordinates, latitudinalMeters: 200, longitudinalMeters: 200))
      }
      .onChange(of: mapSelection) { oldValue, newValue in
        if newValue != nil {
          showPlaceDetails = true
        }
        
        Task {
          await fetchLookAroundPreview()
        }
      }
      .overlay(alignment: .bottom) {
        TextField("search", text: $query)
          .padding(12)
          .background(.white)
          .padding()
      }
      .onSubmit(of: .text) {
        Task {
          await searchPlaces()
        }
      }
      .sheet(isPresented: $showPlaceDetails, onDismiss: {
        mapSelection = nil
      }) {
        PlaceDetails(mapSelection: $mapSelection, lookAround: $lookAround, getDirection: $getDirections, getRoute: fetchRoute)
          .task {
            await fetchLookAroundPreview()
          }
      }
    }
    else {
      ProgressView()
        .tint(.red)
    }
  }
}

extension ContentView {
  func searchPlaces() async {
    guard let coordinates = locationManager.currentCoordinates else { return }
    
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    request.region = MKCoordinateRegion(
      center: coordinates,
      latitudinalMeters: 2000,
      longitudinalMeters: 2000
    )
    camera = .region(MKCoordinateRegion(
      center: coordinates,
      latitudinalMeters: 1000,
      longitudinalMeters: 1000
    ))
    
    let res = try? await MKLocalSearch(request: request).start()
    searchResults = res?.mapItems ?? []
  }
  
  @MainActor func fetchLookAroundPreview() async {
    if let mapSelection {
      lookAround = nil
      
      Task {
        let req = MKLookAroundSceneRequest(mapItem: mapSelection)
        lookAround = try? await req.scene
      }
    }
  }
  
  func fetchRoute() {
    if let mapSelection {
      let request = MKDirections.Request()
      
      guard let coordinates = locationManager.currentCoordinates else { return }
      
      request.source = MKMapItem(placemark: .init(coordinate: coordinates))
      request.destination = mapSelection
      
      Task {
        let result = try? await MKDirections(request: request).calculate()
        route = result?.routes.first
        routeDestination = mapSelection
        
        withAnimation(.snappy) {
          routeDisplaying = true
          showPlaceDetails = false
          
          if let rect = route?.polyline.boundingMapRect, routeDisplaying {
            camera = .rect(rect)
          }
        }
      }
    }
  }
}

#Preview {
  ContentView()
}



