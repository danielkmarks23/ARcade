//
//  ActionButton.swift
//  ARcade
//
//  Created by Daniel Marks on 27/02/2022.
//

import SwiftUI

struct ActionButton: View {
    
    let systemIconName: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: systemIconName)
                .font(.system(size: 50, weight: .light, design: .default))
                .foregroundColor(.white)
                .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 75, height: 75)

    }
}
