//
//  Terrarium.swift
//  Garden_Of_Memory
//
//  Created by Yu Ching Wong on 13/5/2024.
//

import Foundation
import Observation
import SwiftUI

enum TerrariumState {
    case open
    case close
}

@Observable
class FullTerrarium {
    
    var terrariumState = TerrariumState.close
    
}

struct ImmersiveTerrariumState {
    static var terrarium = false
}
