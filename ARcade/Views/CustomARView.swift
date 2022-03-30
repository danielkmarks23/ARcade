//
//  CustomARView.swift
//  ARcade
//
//  Created by Daniel Marks on 26/02/2022.
//

import RealityKit
import ARKit
import FocusEntity
import SwiftUI
import Combine

class CustomARView: ARView {
    
    var focusEntity: FocusEntity?
    var sessionSettings: SessionManager
    var modelDeletionManager: ModelDeletionManager
    var defaultConfiguration: ARWorldTrackingConfiguration {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        return config
    }
    
    
    private var peopleOcclusionCancellable: AnyCancellable?
    private var objectOcclusionCancellable: AnyCancellable?
    private var lidarDebugCancellable: AnyCancellable?
    private var multiuserCancellable: AnyCancellable?
    
    required init(frame frameRect: CGRect, sessionSettings: SessionManager, modelDeletionManager: ModelDeletionManager) {
        self.sessionSettings = sessionSettings
        self.modelDeletionManager = modelDeletionManager
        
        super.init(frame: frameRect)
        
        focusEntity = FocusEntity(on: self, focus: .classic)
        configure()
        initializeSettings()
        setupSubscribers()
        enableObjectDeletion()
    }
    
    @objc required dynamic init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        session.run(defaultConfiguration)
    }
    
    private func initializeSettings() {
        updatePeopleOcclusion(isEnabled: sessionSettings.isPeopleOcclusionEnabled)
        updateObjectOcclusion(isEnabled: sessionSettings.isObjectOcclusionEnabled)
        updateLidarDebug(isEnabled: sessionSettings.isLidarDebugEnabled)
        updateMultiuser(isEnabled: sessionSettings.isMultiuserEnabled)
    }
}

// MARK: - SessionSettings Subscribers

extension CustomARView {
    
    private func setupSubscribers() {
        peopleOcclusionCancellable = sessionSettings.$isPeopleOcclusionEnabled.sink { [weak self] isEnabled in
            self?.updatePeopleOcclusion(isEnabled: isEnabled)
        }
        
        objectOcclusionCancellable = sessionSettings.$isObjectOcclusionEnabled.sink { [weak self] isEnabled in
            self?.updateObjectOcclusion(isEnabled: isEnabled)
        }
        
        lidarDebugCancellable = sessionSettings.$isLidarDebugEnabled.sink { [weak self] isEnabled in
            self?.updateLidarDebug(isEnabled: isEnabled)
        }
        
        multiuserCancellable = sessionSettings.$isMultiuserEnabled.sink { [weak self] isEnabled in
            self?.updateMultiuser(isEnabled: isEnabled)
        }
    }
    
    private func updatePeopleOcclusion(isEnabled: Bool) {
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            return
        }
        
        guard let configuration = session.configuration as? ARWorldTrackingConfiguration else {
            return
        }
        
        Logger.log(type: .info, message: "isPeopleOcclusionEnabled = " + String(describing: isEnabled))
        
        if configuration.frameSemantics.contains(.personSegmentationWithDepth) {
            configuration.frameSemantics.remove(.personSegmentationWithDepth)
        } else {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
        session.run(configuration)
    }
    
    private func updateObjectOcclusion(isEnabled: Bool) {
        Logger.log(type: .info, message: "isObjectOcclusionEnabled = " + String(describing: isEnabled))
        
        if environment.sceneUnderstanding.options.contains(.occlusion) {
            environment.sceneUnderstanding.options.remove(.occlusion)
        } else {
            environment.sceneUnderstanding.options.insert(.occlusion)
        }
    }
    
    private func updateLidarDebug(isEnabled: Bool) {
        Logger.log(type: .info, message: "isLidarDebugEnabled = " + String(describing: isEnabled))
        
        if debugOptions.contains(.showSceneUnderstanding) {
            debugOptions.remove(.showSceneUnderstanding)
        } else {
            debugOptions.insert(.showSceneUnderstanding)
        }
    }
    
    private func updateMultiuser(isEnabled: Bool) {
        Logger.log(type: .info, message: "isMultiuserEnabled = " + String(describing: isEnabled))
    }
}

// MARK: - Object Deletion Methods

extension CustomARView {
    
    func enableObjectDeletion() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        longPressGesture.minimumPressDuration = 0.2
        self.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.location(in: self)
        
        if let entity = self.entity(at: location) as? ModelEntity {
            modelDeletionManager.entitySelectedForDeletion = entity
        }
    }
}
