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
  
  var body: some View {
    if let coordinates = locationManager.currentCoordinates {
      Map(position: $camera, selection: $mapSelection) {
        UserAnnotation()
        
        ForEach(searchResults, id: \.self) { item in
          let place = item.placemark
          Marker(place.title ?? "", coordinate: place.coordinate)
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
        
        fetchLookAroundPreview()
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
      .sheet(isPresented: $showPlaceDetails) {
        VStack {
          if let place = mapSelection {
            Text("\(place.placemark.title ?? "")")
            Text("\(place.placemark.subtitle ?? "")")
          }
          
          if let scene = lookAround {
            LookAroundPreview(initialScene: scene, allowsNavigation: true, showsRoadLabels: true)
          } else {
            ContentUnavailableView("No Preview", systemImage: "eye.slash")
          }
        }
        .presentationDetents([.medium])
        .onAppear {
          fetchLookAroundPreview()
        }
        .onDisappear {
          mapSelection = nil
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
    
    print(coordinates)
    
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
    print(searchResults)
  }
  
  func fetchLookAroundPreview() {
    if let mapSelection {
      lookAround = nil
      
      Task {
        let req = MKLookAroundSceneRequest(mapItem: mapSelection)
        lookAround = try? await req.scene
      }
    }
  }
}

#Preview {
  ContentView()
}
