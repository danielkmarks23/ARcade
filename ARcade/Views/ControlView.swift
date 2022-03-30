//
//  ControlView.swift
//  ARcade
//
//  Created by Daniel Marks on 25/02/2022.
//

import SwiftUI
import simd

enum ControlModes: String, CaseIterable {
    case browse = "Browse"
    case scene = "Scene"
}

struct ControlView: View {
    @Binding var selectedControlMode: Int
    @Binding var isControlsVisibility: Bool
    @Binding var isBrowseActive: Bool
    @Binding var isSettingsActive: Bool
    
    var body: some View {
        VStack {
            ControlVisibilityToggleButton(isControlsVisibility: $isControlsVisibility)
            
            Spacer()
            
            if isControlsVisibility {
                ControlModePicker(selectedControlMode: $selectedControlMode)
                ControlButtonBar(isBrowseActive: $isBrowseActive, isSettingsActive: $isSettingsActive, selectedControlMode: selectedControlMode)
                    .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }
}

struct ControlVisibilityToggleButton: View {
    
    @Binding var isControlsVisibility: Bool
    
    var body: some View {
        HStack {
            Spacer()
            
            ZStack {
                Color.black.opacity(0.25)
                
                ControlButton(systemIconName: isControlsVisibility ? "rectangle" : "slider.horizontal.below.rectangle", size: 25) {
                    Logger.log(type: .debug, message: "ControlVisibiltyToggle button tapped")
                    withAnimation {
                        isControlsVisibility.toggle()
                    }
                }
            }
            .frame(width: 50, height: 50)
            .cornerRadius(8)
        }
        .padding(.top, 45)
        .padding(.trailing, 25)
    }
}

struct ControlModePicker: View {
    
    @Binding var selectedControlMode: Int
    let controlModes = ControlModes.allCases
    
    init(selectedControlMode: Binding<Int>) {
        self._selectedControlMode = selectedControlMode
        UISegmentedControl.appearance().selectedSegmentTintColor = .clear
        UISegmentedControl.appearance().backgroundColor = .black.withAlphaComponent(0.25)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.green], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
    }
    
    var body: some View {
        Picker(selection: $selectedControlMode, label: Text("Select a Control Mode")) {
            ForEach(0..<controlModes.count) { index in
                Text(controlModes[index].rawValue.uppercased())
                    .tag(index)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .frame(maxWidth: 400)
        .padding(.horizontal, 10)
    }
}

struct ControlButtonBar: View {
    
    @Binding var isBrowseActive: Bool
    @Binding var isSettingsActive: Bool
    var selectedControlMode: Int
    
    var body: some View {
        HStack(alignment: .center) {
            if selectedControlMode == 1 {
                SceneButtons()
            } else {
                BrowseButtons(isBrowseActive: $isBrowseActive, isSettingsActive: $isSettingsActive)
            }
        }
        .padding(30)
        .background(Color.black.opacity(0.25))
    }
    
}

struct BrowseButtons: View {
    
    @EnvironmentObject var placemntSettings: PlacementManager
    @Binding var isBrowseActive: Bool
    @Binding var isSettingsActive: Bool
    
    var body: some View {
        HStack {
            
            // Most Recent Placed Button
            if !placemntSettings.recentlyPlaced.isEmpty {
                MostRecentlyPlacedButton()
            } else {
                Spacer()
                    .frame(width: 50, height: 50)
            }
            
            Spacer()
            
            // Browse Button
            ControlButton(systemIconName: "square.grid.2x2", size: 35) {
                Logger.log(type: .debug, message: "Browse button tapped")
                isBrowseActive.toggle()
            }
            .sheet(isPresented: $isBrowseActive) {
                BrowseView(isBrowseActive: $isBrowseActive)
            }
            
            Spacer()
            
            // Settings Button
            ControlButton(systemIconName: "slider.horizontal.3", size: 35) {
                Logger.log(type: .debug, message: "Settings button tapped")
                isSettingsActive.toggle()
            }
            .sheet(isPresented: $isSettingsActive) {
                SettingsView(isSettingsActive: $isSettingsActive)
            }
        }
    }
}

struct SceneButtons: View {
    
    @EnvironmentObject var sceneManger: SceneManager
    
    var body: some View {
        
        if sceneManger.isPersistenceAvailable {
            ControlButton(systemIconName: "icloud.and.arrow.up", size: 35) {
                Logger.log(type: .debug, message: "Save Scene button tapped")
                sceneManger.shouldSaveSceneToFileSystem = true
            }
            
            Spacer()
        }
        
        if sceneManger.scenePersistenceData != nil {
            ControlButton(systemIconName: "icloud.and.arrow.down", size: 35) {
                Logger.log(type: .debug, message: "Load Scene button tapped")
                sceneManger.shouldLoadSceneFromFileSystem = true
            }
            
            Spacer()
        }
        
        ControlButton(systemIconName: "trash", size: 35) {
            Logger.log(type: .debug, message: "Clear Scene button tapped")
            
            for anchorEntity in sceneManger.anchorEntites {
                Logger.log(type: .info, message: "Removing anchorEntity with id: " + String(describing: anchorEntity.anchorIdentifier))
                
                anchorEntity.removeFromParent()
            }
        }
    }
}

struct ControlButton: View {
    
    let systemIconName: String
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemIconName)
                .font(.system(size: size))
                .foregroundColor(.white)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 50, height: 50)
    }
}

struct MostRecentlyPlacedButton: View {
    @EnvironmentObject var placementSettings: PlacementManager
    
    var body: some View {
        Button {
            Logger.log(type: .debug, message: "Most Recently Placed button tapped")
            placementSettings.selectedModel = placementSettings.recentlyPlaced.last
        } label: {
            if let mostRecentlyPlacedModel = placementSettings.recentlyPlaced.last {
                Image(mostRecentlyPlacedModel.name)
                    .resizable()
                    .frame(width: 46)
                    .aspectRatio(1/1, contentMode: .fit)
            } else {
                EmptyView()
            }
        }
        .frame(width: 50, height: 50)
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct ControlView_Previews: PreviewProvider {
    static var previews: some View {
        ControlView(selectedControlMode: .constant(0), isControlsVisibility: .constant(true), isBrowseActive: .constant(false), isSettingsActive: .constant(false))
    }
}
