//
//  DeletionView.swift
//  ARcade
//
//  Created by Daniel Marks on 27/02/2022.
//

import SwiftUI

struct DeletionView: View {
    
    @EnvironmentObject var sceneManager: SceneManager
    @EnvironmentObject var modelDeletionManager: ModelDeletionManager
    
    var body: some View {
        HStack {
            Spacer()
            
            ActionButton(systemIconName: "xmark.circle.fill") {
                Logger.log(type: .debug, message: "Cancel Deletion button tapped")
                
                modelDeletionManager.entitySelectedForDeletion = nil
            }
            
            Spacer()
            
            ActionButton(systemIconName: "trash.circle.fill") {
                Logger.log(type: .debug, message: "Confirm Deletion button tapped")
                
                guard let anchor = modelDeletionManager.entitySelectedForDeletion?.anchor else { return }
                
                let anchoringIdentifier = anchor.anchorIdentifier
                
                if let index = sceneManager.anchorEntites.firstIndex(where: { $0.anchorIdentifier == anchoringIdentifier }) {
                    Logger.log(type: .info, message: "Deleteing anchorEntity with id: " + String(describing: anchoringIdentifier))
                    sceneManager.anchorEntites.remove(at: index)
                }
                
                anchor.removeFromParent()
                modelDeletionManager.entitySelectedForDeletion = nil
            }
            
            Spacer()
        }
        .padding(.bottom, 30)
    }
}


struct DeletionView_Previews: PreviewProvider {
    static var previews: some View {
        DeletionView()
    }
}
