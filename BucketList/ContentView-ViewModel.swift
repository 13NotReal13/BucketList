//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Иван Семикин on 08/11/2024.
//

import Foundation
import LocalAuthentication
import MapKit
import SwiftUI

extension ContentView {
    @Observable
    final class ViewModel: ObservableObject {
        private(set) var locations: [Location]
        var selectedPlace: Location?
        var isUnlocked = false
        var showAlert = false
        var alertMessage = ""

        let savePath = URL.documentsDirectory.appending(path: "SavedPlaces")
        
        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }
        
        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomic, .completeFileProtection])
            } catch {
                print("Unable to save data.")
            }
        }
        
        func addLocation(_ coordinate: CLLocationCoordinate2D) {
            let newLocation = Location(
                id: UUID(),
                name: "New Location",
                description: "",
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
            locations.append(newLocation)
            save()
        }
        
        func updateLocation(location: Location) {
            guard let selectedPlace else { return }
            
            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = location
                save()
            }
        }
        
        func authenticate() {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate yourself to unlock places."
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                    DispatchQueue.main.async {
                        if success {
                            self?.isUnlocked = true
                        } else {
                            self?.alertMessage = authenticationError?.localizedDescription ?? "Unknown error"
                            self?.showAlert = true
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.alertMessage = error?.localizedDescription ?? "Biometric authentication not available."
                    self.showAlert = true
                }
            }
        }
    }
}
