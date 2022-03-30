//
//  ContentView.swift
//  ARcade
//
//  Created by Daniel Marks on 25/02/2022.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @EnvironmentObject var placementSettings: PlacementManager
    @EnvironmentObject var modelDeletionManager: ModelDeletionManager
    
    @State private var selectedControlMode: Int = 0
    @State private var isControlsVisible: Bool = true
    @State private var isBrowseActive: Bool = false
    @State private var isSettingsActive: Bool = false
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            ARViewContainer()
            
            if placementSettings.selectedModel != nil {
                PlacementView()
            } else if modelDeletionManager.entitySelectedForDeletion != nil {
                DeletionView()
            } else {
                ControlView(selectedControlMode: $selectedControlMode, isControlsVisibility: $isControlsVisible, isBrowseActive: $isBrowseActive, isSettingsActive: $isSettingsActive)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PlacementManager())
            .environmentObject(SessionManager())
            .environmentObject(SceneManager())
            .environmentObject(ModelDeletionManager())
    }
}
