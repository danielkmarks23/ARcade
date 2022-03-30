//
//  ARViewContainer.swift
//  ARcade
//
//  Created by Daniel Marks on 26/02/2022.
//

import SwiftUI
import RealityKit
import FocusEntity
import ARKit

private let anchorNamePrefix = "model-"

struct ARViewContainer: UIViewRepresentable {
    
    @EnvironmentObject var placementSettings: PlacementManager
    @EnvironmentObject var sessionSettings: SessionManager
    @EnvironmentObject var sceneManager: SceneManager
    @EnvironmentObject var modelDeletionManager: ModelDeletionManager
    @EnvironmentObject var modelsManager: ModelsManager
    
#if !targetEnvironment(simulator)
    func makeUIView(context: Context) -> some CustomARView {
        
        let arView = CustomARView(frame: .zero, sessionSettings: sessionSettings, modelDeletionManager: modelDeletionManager)
        arView.session.delegate = context.coordinator
        
        // Subscribe to SceneEvents.Update
        placementSettings.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { event in
            
            updateScene(for: arView)
            updatePersistenceAvailability(for: arView)
            handlePersistence(for: arView)
        })
        
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }

    private func updateScene(for arView: CustomARView) {
        
        // Only display focusEntity when the user has selected a model for placememt
        arView.focusEntity?.isEnabled = placementSettings.selectedModel != nil
        
        if let modelAnchor = placementSettings.modelsConfirmedForPlacement.popLast(), let modelEntity = modelAnchor.model.modelEntity {
            
            if let anchor = modelAnchor.anchor {
                place(modelEntity, for: anchor, in: arView)
            } else if let transform = getTransformForPlacement(in: arView) {
                let anchorName = anchorNamePrefix + modelAnchor.model.name
                let anchor = ARAnchor(name: anchorName, transform: transform)
                
                place(modelEntity, for: anchor, in: arView)
                
                arView.session.add(anchor: anchor)
                
                placementSettings.recentlyPlaced.append(modelAnchor.model)
            }
        }
    }
    
    private func place(_ modelEntity: ModelEntity, for anchor: ARAnchor, in arView: ARView) {
        
        // 1. Clone Entity. This creates an identical copy of modelEntity and refrences the same model. This also allows us to have multiple models of the same asset in our scene.
        let clonedEntity = modelEntity.clone(recursive: true)
        
        // 2. Enable translation and rotation gesture.
        clonedEntity.generateCollisionShapes(recursive: true)
        arView.installGestures([.translation, .rotation], for: clonedEntity)
        
        // 3. Create an anchorEntity and add clonedEntity to it.
        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(clonedEntity)
        anchorEntity.anchoring = AnchoringComponent(anchor)
        
        // 4. Add the anchorEntity to arView.scene
        arView.scene.addAnchor(anchorEntity)
        
        sceneManager.anchorEntites.append(anchorEntity)
        
        Logger.log(type: .info, message: "Added modelEntity to scene.")
    }
    
    private func getTransformForPlacement(in arView: ARView) -> simd_float4x4? {
        guard let query = arView.makeRaycastQuery(from: arView.center, allowing: .estimatedPlane, alignment: .any), let raycastResult = arView.session.raycast(query).first else {
            return nil
        }
        
        return raycastResult.worldTransform
    }
    
#else
    
    func makeUIView(context: Context) -> UIView {
        UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
#endif
}

// MARK: - Persistence

extension ARViewContainer {
    private func updatePersistenceAvailability(for arView: ARView) {
        guard let currentFrame = arView.session.currentFrame else {
            return
        }
        
        if currentFrame.worldMappingStatus == .mapped || currentFrame.worldMappingStatus == .extending {
            sceneManager.isPersistenceAvailable = !sceneManager.anchorEntites.isEmpty
        } else {
            sceneManager.isPersistenceAvailable = false
        }
    }
    
    private func handlePersistence(for arView: CustomARView) {
        if sceneManager.shouldSaveSceneToFileSystem {
            ScenePersistenceHelper.saveScene(for: arView, at: sceneManager.persistenceURL)
            
            sceneManager.shouldSaveSceneToFileSystem = false
        } else if sceneManager.shouldLoadSceneFromFileSystem {
            
            guard let scenePersistenceData = sceneManager.scenePersistenceData else {
                Logger.log(type: .warning, message: "Unable to retreive scenePersistenceData. Canceled loadScene operation")
                sceneManager.shouldLoadSceneFromFileSystem = false
                
                return
            }
            
            modelsManager.clearModelEntitiesFromMemory()
            sceneManager.anchorEntites.removeAll(keepingCapacity: true)
            ScenePersistenceHelper.loadScene(for: arView, with: scenePersistenceData)
            sceneManager.shouldLoadSceneFromFileSystem = false
        }
    }
}

// MARK: - ARSesssionDelegate + Coordinator

extension ARViewContainer {
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let anchorName = anchor.name, anchorName.hasPrefix(anchorName) {
                    let modelName = anchorName.dropFirst(anchorNamePrefix.count)
                    Logger.log(type: .info, message: "ARSession: didAdd anchor for modelName: \(modelName)")
                    
                    guard let model = parent.modelsManager.models.first(where: { $0.name == modelName }) else {
                        Logger.log(type: .warning, message: "Unable to retrieve model from modelsManager")
                        return
                    }
                    
                    if model.modelEntity == nil {
                        model.asyncLoadModelEntity { completed, error in
                            if completed {
                                let modelAnchor = ModelAnchor(model: model, anchor: anchor)
                                self.parent.placementSettings.modelsConfirmedForPlacement.append(modelAnchor)
                                Logger.log(type: .info, message: "Adding modelAnchor with name: \(model.name)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}
