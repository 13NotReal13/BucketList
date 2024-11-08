//
//  EditView.swift
//  BucketList
//
//  Created by Иван Семикин on 08/11/2024.
//

import SwiftUI

struct EditView: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (Location) -> Void
    var location: Location
    
    @StateObject private var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Place name", text: $viewModel.name)
                    TextField("Description", text: $viewModel.description)
                }
                
                Section {
                    switch viewModel.loadingState {
                    case .loading:
                        Text("Loading...")
                    case .loaded:
                        ForEach(viewModel.pages, id: \.pageId) { page in
                            Text(page.title)
                                .font(.headline)
                            
                            + Text(": ") +
                            
                            Text(page.description)
                                .italic()
                        }
                    case .failed:
                        Text("Please try again later...")
                    }
                }
            }
            .navigationTitle("Place details")
            .toolbar {
                Button("Save") {
                    var newLocation = location
                    newLocation.id = UUID()
                    newLocation.name = viewModel.name
                    newLocation.description = viewModel.description
                    
                    onSave(newLocation)
                    dismiss()
                }
            }
            .task {
                await viewModel.fetchNearbyPlaces()
            }
        }
    }
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.location = location
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: ViewModel(location: location))
    }
}

#Preview {
    EditView(location: .example) { _ in }
}
