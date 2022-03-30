//
//  ModelsManager.swift
//  ARcade
//
//  Created by Daniel Marks on 29/03/2022.
//

import Foundation

class ModelsManager: ObservableObject {
    @Published var models: [Model] = []
    
    init() {
        let pacman = Model(name: "Pacman_Arcade", category: .midway)
        let asteroids = Model(name: "Asteroids_Arcade", category: .atari)
        let centipede = Model(name: "Centipede_Arcade", category: .atari, scaleCompensation: 1.0)
        let defender = Model(name: "Defender_Arcade", category: .williams)
        let donkeyKong = Model(name: "DonkeyKong_Arcade", category: .nintendo)
        let mortalKombat = Model(name: "MortalKombat_Arcade", category: .midway)
        let qbert = Model(name: "Q*bert_Arcade", category: .gottlieb)
        let spaceInvaders = Model(name: "SpaceInvaders_Arcade", category: .taito)
        models += [pacman, asteroids, centipede, defender, donkeyKong, mortalKombat, qbert, spaceInvaders]
    }
    
    func get(category: ModelCategory) -> [Model] {
        models.filter {
            $0.category == category
        }
    }
    
    func clearModelEntitiesFromMemory() {
        for model in models {
            model.modelEntity = nil
        }
    }
}
