//
//  ARcadeApp.swift
//  ARcade
//
//  Created by Daniel Marks on 25/02/2022.
//

import SwiftUI

@main
struct ARcadeApp: App {
    
    @StateObject var placementSettings = PlacementManager()
    @StateObject var sessionSettings = SessionManager()
    @StateObject var sceneManager = SceneManager()
    @StateObject var modelDeletionManager = ModelDeletionManager()
    @StateObject var modelsManager = ModelsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(placementSettings)
                .environmentObject(sessionSettings)
                .environmentObject(sceneManager)
                .environmentObject(modelDeletionManager)
                .environmentObject(modelsManager)
        }
    }
}
