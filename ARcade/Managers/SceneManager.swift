//
//  SceneManager.swift
//  ARcade
//
//  Created by Daniel Marks on 05/03/2022.
//

import Foundation
import RealityKit

class SceneManager: ObservableObject {
    @Published var isPersistenceAvailable: Bool = false
    @Published var anchorEntites: [AnchorEntity] = [] // Keeps track of anchorEntities in the scene
    
    var shouldSaveSceneToFileSystem: Bool = false // Flag to trigger save scene to file system function
    var shouldLoadSceneFromFileSystem: Bool = false // Flag to trigger load scene file system function
    
    lazy var persistenceURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("arcade.persistence")
        } catch {
            fatalError("Unable to get persistenceURL: \(error.localizedDescription)")
        }
    }()
    
    var scenePersistenceData: Data? {
        return try? Data(contentsOf: persistenceURL)
    }
}
