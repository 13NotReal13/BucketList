//
//  ContentView.swift
//  BucketList
//
//  Created by Иван Семикин on 06/11/2024.
//

import SwiftUI
import MapKit

struct ContentView: View {
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 56, longitude: -3),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    )
    
    @State private var viewModel = ViewModel()
    @State private var mapType: MKMapType = .standard

    var body: some View {
        if !viewModel.isUnlocked {
            VStack {
                Picker("Map Type", selection: $mapType) {
                    Text("Standard").tag(MKMapType.standard)
                    Text("Hybrid").tag(MKMapType.hybrid)
                }
                .pickerStyle(.segmented)
                .padding()
                
                MapReader { proxy in
                    Map(initialPosition: startPosition) {
                        ForEach(viewModel.locations) { location in
                            Annotation(location.name, coordinate: location.coordinate) {
                                Image(systemName: "star")
                                    .resizable()
                                    .foregroundStyle(.red)
                                    .frame(width: 44, height: 44)
                                    .background(.white)
                                    .clipShape(.circle)
                                    .onTapGesture {
                                        viewModel.selectedPlace = location
                                    }
                            }
                        }
                    }
                    .mapStyle(mapType == .standard ? .standard : .hybrid)
                    .onTapGesture { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            viewModel.addLocation(coordinate)
                        }
                    }
                    .sheet(item: $viewModel.selectedPlace) { place in
                        EditView(location: place) {
                            viewModel.updateLocation(location: $0)
                        }
                    }
                }
            }
        } else {
            Button("Unlock Places", action: viewModel.authenticate)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(.capsule)
                .alert("Authentication Error", isPresented: $viewModel.showAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(viewModel.alertMessage)
                }
        }
    }
}

#Preview {
    ContentView()
}

#Preview {
    ContentView()
}
