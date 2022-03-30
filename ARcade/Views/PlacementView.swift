//
//  PlacementView.swift
//  ARcade
//
//  Created by Daniel Marks on 26/02/2022.
//

import SwiftUI

struct PlacementView: View {
    
    @EnvironmentObject var placementSettings: PlacementManager
    
    var body: some View {
        HStack {
            Spacer()
            
            ActionButton(systemIconName: "xmark.circle.fill") {
                Logger.log(type: .debug, message: "Cancel placement button tapped")
                placementSettings.selectedModel = nil
            }
            
            Spacer()
            
            ActionButton(systemIconName: "checkmark.circle.fill") {
                Logger.log(type: .debug, message: "Confirm placement button tapped")
                
                let modelAnchor = ModelAnchor(model: placementSettings.selectedModel!, anchor: nil)
                placementSettings.modelsConfirmedForPlacement.append(modelAnchor)
                placementSettings.selectedModel = nil
            }
            
            Spacer()
        }
        .padding(.bottom, 30)
    }
}

struct PlacementView_Previews: PreviewProvider {
    static var previews: some View {
        PlacementView()
    }
}
