//
//  Model.swift
//  ARcade
//
//  Created by Daniel Marks on 26/02/2022.
//

import SwiftUI
import RealityKit
import Combine

enum ModelCategory: String, CaseIterable {
    case atari = "Atari"
    case dataEast = "Data East"
    case gottlieb = "Gottlieb"
    case midway = "Midway"
    case nintendo = "Nintendo"
    case sega = "Sega"
    case taito = "Taito"
    case williams = "Williams"
    
    var label: String {
        self.rawValue
    }
}

class Model: Equatable {
    
    var name: String
    var category: ModelCategory
    var modelEntity: ModelEntity?
    var scaleCompensation: Float
    
    private var cancellable: AnyCancellable?
    
    init(name: String, category: ModelCategory, scaleCompensation: Float = 0.5) {
        self.name = name
        self.category = category
        self.scaleCompensation = scaleCompensation
    }
    
    func asyncLoadModelEntity(completionHandler: @escaping (_ completed: Bool, _ error: Error?) -> Void) {

        cancellable = ModelEntity.loadModelAsync(named: name + ".usdz")
            .sink { completion in
                switch completion {
                case .failure(let error):
                    Logger.log(type: .error, message: "Unable to load modelEntity for \(self.name).\nError: \(error.localizedDescription)")
                    completionHandler(false, error)
                case .finished:
                    break
                }
            } receiveValue: { modelEntity in
                self.modelEntity = modelEntity
                self.modelEntity?.scale *= self.scaleCompensation
                completionHandler(true, nil)
                Logger.log(type: .success, message: "Model Entity for \(self.name) has been loaded.")
            }

    }
    
    static func == (lhs: Model, rhs: Model) -> Bool {
        lhs.name == rhs.name && lhs.category == rhs.category
    }
}
