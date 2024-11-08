//
//  EditView-ViewModel.swift
//  BucketList
//
//  Created by Иван Семикин on 08/11/2024.
//

import SwiftUI
import MapKit

extension EditView {
    final class ViewModel: ObservableObject {
        enum LoadingState {
            case loading, loaded, failed
        }
        
        var name: String
        var description: String
        var loadingState = LoadingState.loading
        var pages: [Page] = []
        
        var location: Location
        
        init(location: Location) {
            self.location = location
            self.name = location.name
            self.description = location.description
        }
        
        func fetchNearbyPlaces() async {
            let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.latitude)%7C\(location.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
            
            guard let url = URL(string: urlString) else {
                print("Bad URL: \(urlString)")
                return
            }
            
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                }
                
                let items = try JSONDecoder().decode(Result.self, from: data)
                pages = items.query.pages.values.sorted { $0.title < $1.title }
                loadingState = .loaded
            } catch {
                print("Error: \(error.localizedDescription)")
                loadingState = .failed
            }
        }
    }
}
