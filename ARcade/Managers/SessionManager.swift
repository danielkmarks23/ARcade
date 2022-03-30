//
//  SessionManager.swift
//  ARcade
//
//  Created by Daniel Marks on 04/03/2022.
//

import SwiftUI

class SessionManager: ObservableObject {
    @Published var isPeopleOcclusionEnabled: Bool = false
    @Published var isObjectOcclusionEnabled: Bool = false
    @Published var isLidarDebugEnabled: Bool = false
    @Published var isMultiuserEnabled: Bool = false
}
