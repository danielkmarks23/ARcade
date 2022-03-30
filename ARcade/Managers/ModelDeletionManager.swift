//
//  ModelDeletionManager.swift
//  ARcade
//
//  Created by Daniel Marks on 27/02/2022.
//

import SwiftUI
import RealityKit

class ModelDeletionManager: ObservableObject {
    
    @Published var entitySelectedForDeletion: ModelEntity? = nil {
        willSet(newValue) {
            if self.entitySelectedForDeletion == nil, let newlySelectedModelEntity = newValue {
                
                Logger.log(type: .info, message: "Selecting new entitySelectedForDeletion, no previous selection.")
                
                // Highlight newlySelectedModelEntity
                let component = ModelDebugOptionsComponent(visualizationMode: .lightingDiffuse)
                newlySelectedModelEntity.modelDebugOptions = component
            } else if let previouslySelectedModelEntity = self.entitySelectedForDeletion, let newlySelectedModelEntity = newValue {
                
                Logger.log(type: .info, message: "Selecting new entitySelectedForDeletion, had previous selection.")
                
                // Un-highlight previouslySelectedModelEntity
                previouslySelectedModelEntity.modelDebugOptions = nil
                
                // Highlight newlySelectedModelEntity
                let component = ModelDebugOptionsComponent(visualizationMode: .lightingDiffuse)
                newlySelectedModelEntity.modelDebugOptions = component
            } else if newValue == nil {
                
                Logger.log(type: .info, message: "Clearing entitySelectedForDeletion.")
                
                // Un-highlight previouslySelectedModelEntity
                entitySelectedForDeletion?.modelDebugOptions = nil
            }
        }
    }
}
