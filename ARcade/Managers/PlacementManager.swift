//
//  PlacementManager.swift
//  ARcade
//
//  Created by Daniel Marks on 26/02/2022.
//

import SwiftUI
import RealityKit
import Combine
import ARKit

struct ModelAnchor {
    var model: Model
    var anchor: ARAnchor?
}

class PlacementManager: ObservableObject {
    
    // Gets set when the user selects a model in BrowseView
    @Published var selectedModel: Model? {
        willSet(newValue) {
            Logger.log(type: .info, message: "Setting selectedModel to \(String(describing: newValue?.name))")
        }
    }
    
    // This property will keep track of all the content that has been confirmed for placement in the scene
    var modelsConfirmedForPlacement: [ModelAnchor] = []
    
    // Retains a record of placed models in the scene. The last element in the array is the most recent placed model
    @Published var recentlyPlaced: [Model] = []
    
    // Retains the cancellable object for our SceneEvents.Update subscriber
    var sceneObserver: Cancellable?
}
