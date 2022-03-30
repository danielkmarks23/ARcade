//
//  ScenePersistenceHelper.swift
//  ARcade
//
//  Created by Daniel Marks on 19/03/2022.
//

import Foundation
import RealityKit
import ARKit

class ScenePersistenceHelper {
    
    class func saveScene(for arView: CustomARView, at persistenceURL: URL) {
        Logger.log(type: .info, message: "Save scene to local file system")
        
        arView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap else {
                Logger.log(type: .error, message: "Persistence Error: Unable to get world map: \(String(describing: error?.localizedDescription))")
                // TODO: Error to user
                return
            }
            
            do {
                let sceneData = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                
                try sceneData.write(to: persistenceURL, options: [.atomic])
                // TODO: Alert user
            } catch {
                Logger.log(type: .error, message: "Persistence Error: Can't save scene to local filesystem: \(error.localizedDescription)")
                // TODO: Error to user
            }
        }
    }
    
    class func loadScene(for arView: CustomARView, with scenePersistenceData: Data) {
        Logger.log(type: .info, message: "Load scene from local file system")
        
        let worldMap: ARWorldMap = {
            do {
                guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: scenePersistenceData) else {
                    Logger.log(type: .fatal, message: "Persistence Error: No ARWorldMap in archive")
                    fatalError("Persistence Error: No ARWorldMap in archive")
                }
                
                return worldMap
            } catch {
                Logger.log(type: .fatal, message: "Persistence Error: Unable to unarchive ARWorldMap from scenePersistenceData: \(error.localizedDescription)")
                fatalError("Persistence Error: Unable to unarchive ARWorldMap from scenePersistenceData: \(error.localizedDescription)")
                // TODO: Error to user
            }
        }()
        
        let newConfig = arView.defaultConfiguration
        newConfig.initialWorldMap = worldMap
        arView.session.run(newConfig, options: [.resetTracking, .removeExistingAnchors])
    }
}
