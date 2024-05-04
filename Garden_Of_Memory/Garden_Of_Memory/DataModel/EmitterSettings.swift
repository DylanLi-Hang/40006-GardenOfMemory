//
//  EmitterSettings.swift
//  Garden_Of_Memory
//
//  Created by Dylan on 4/5/2024.
//

import Foundation
import SwiftUI
import RealityKit

/// Stores the app's state that controls the particle emitter's behavior.
///
/// People can alter the property values with an ``EmitterControls`` view.
@Observable
public class EmitterSettings: ObservableObject {
    typealias ParticleEmitter = ParticleEmitterComponent.ParticleEmitter
    typealias ParticleColor = ParticleEmitter.ParticleColor
    typealias ParticleColorValue = ParticleColor.ColorValue

    /// The entity for the particle emitter.
    let emitterEntity = Entity()

    /// A particle emitter component for the particle emitter, when in edit mode.
    var emitterComponent = ParticleEmitterComponent()

    init() {
        emitterComponent.spawnInheritsParentColor = true
        emitterComponent.speed = 0.001
        emitterComponent.mainEmitter.birthRate = 150
        emitterComponent.emitterShape = .point
        emitterComponent.birthLocation = .surface
        emitterComponent.birthDirection = .normal
        emitterComponent.emitterShapeSize = [0.05, 0.05, 0.05]
        emitterComponent.timing = .repeating(warmUp: 1.5, emit: ParticleEmitterComponent.Timing.VariableDuration(duration: 10, variation: 0))
    }

    /// Update the color properties to reflect the current `emitterComponent`.
    func updateColorControls() {
        switch emitterComponent.mainEmitter.color {
            case .constant(let constantColor):
                switch constantColor {
                    case .random(let colorA, let colorB):
                        color1 = SwiftUI.Color(colorA)
                        color2 = SwiftUI.Color(colorB)
                        colorSetting = .random
                    case .single(let color):
                        color1 = SwiftUI.Color(color)
                        colorSetting = .constant
                    @unknown default: return
                }
            case .evolving(let startColor, let endColor):
                switch (startColor, endColor) {
                    case (.single(let colorA), .single(let colorB)):
                        color1 = SwiftUI.Color(colorA)
                        color2 = SwiftUI.Color(colorB)
                        colorSetting = .evolving
                    default: print("complex color cases are not handled in this app")
                }
            @unknown default: return
        }
    }


    /// A Boolean value that indicates whether a model representing
    /// the emitter's shape is visible, as a visual aid.
    var showEmitter: Bool = false {
        didSet {
            updateEmitter()
        }
    }

    /// Update the emitter's visual representation.
    func updateEmitter() {
        guard showEmitter else {
            emitterEntity.components.remove(ModelComponent.self)
            return
        }

        let eSize = emitterSize
        let modelMesh: MeshResource = switch emitterComponent.emitterShape {
        case .sphere: MeshResource.generateSphere(radius: eSize)
        case .box: MeshResource.generateBox(size: eSize * 2)
        case .plane: MeshResource.generateBox(size: [eSize * 2, eSize * 0.1, eSize * 2])
        case .cone: MeshResource.generateCone(height: eSize * 1.6, radius: eSize)
        case .cylinder: .generateCylinder(height: eSize * 2, radius: eSize)
        case .point: .generateSphere(radius: 0.01)
        default: MeshResource.generateSphere(radius: eSize / 2)
        }
        emitterEntity.components.set(ModelComponent(
            mesh: modelMesh,
            materials: [UnlitMaterial(color: .white.withAlphaComponent(0.1))]
        ))
    }

    /// The size of the emitter's shape, in meters.
    var emitterSize: Float = 0.05 {
        didSet {
            emitterComponent.emitterShapeSize = .init(repeating: emitterSize)
            updateEmitter()
        }
    }

    /// The first of up to two colors in the particle editor.
    var color1 = SwiftUI.Color.red

    /// The second of two colors in the particle editor.
    var color2 = SwiftUI.Color.purple

    /// Represents the state of the color setting.
    enum ColorSetting: String, CaseIterable, Identifiable {
        public var id: Self { self }
        case inherit
        case constant
        case random
        case evolving
    }

    /// A setting that indicates whether the particles' color is constant or
    /// evolving.
    var colorSetting: ColorSetting = .inherit

    /// Updates the color of the particles with the current color settings.
    func updateColors() {
        switch colorSetting {
            case .inherit: setInheritColor()
            case .constant: setConstantColor(color1)
            case .random: setRandomColor(color1, color2)
            case .evolving: setEvolvingColor(color1, color2)
        }
    }

    /// Configures a constant color for the emitter's particles.
    ///
    /// - Parameter swiftUIColor: A SwiftUI color instance.
    func setConstantColor(_ swiftUIColor: SwiftUI.Color) {
        // Create a single color value instance.
        let color1 = ParticleEmitter.Color(swiftUIColor)
        let singleColorValue = ParticleColorValue.single(color1)

        // Create a constant color from the single color value.
        let constantColor = ParticleColor.constant(singleColorValue)

        // Change the particle color for the emitter.
        emitterComponent.mainEmitter.color = constantColor

        // Replace the entity's emitter component with the current configuration.
        emitterEntity.components.set(emitterComponent)
    }

    /// Configures a constant color for the emitter's particles, which the
    /// method randomly selects from a interpolation range between two colors.
    ///
    /// - Parameters:
    ///   - swiftUIColor1: A color instance that represents one end of the range
    ///   of possible colors for the emitter's particles.
    ///   - swiftUIColor2: Another color instance that represents the other end
    ///   of the range of possible colors for the emitter's particles.
    func setRandomColor(_ swiftUIColor1: SwiftUI.Color,
                        _ swiftUIColor2: SwiftUI.Color) {
        // Create a random color value instance between two colors.
        let color1 = ParticleEmitter.Color(swiftUIColor1)
        let color2 = ParticleEmitter.Color(swiftUIColor2)
        let randomColor = ParticleColorValue.random(a: color1, b: color2)

        // Create a constant color from the random color value.
        let constantColor = ParticleColor.constant(randomColor)

        // Change the particle color for the emitter.
        emitterComponent.mainEmitter.color = constantColor

        // Replace the entity's emitter component with the current configuration.
        emitterEntity.components.set(emitterComponent)
    }

    /// Configures the color of the emitter's particles to an evolving color
    /// that gradually shifts from one color to another over time.
    ///
    /// - Parameters:
    ///   - swiftUIColor1: The initial color for the emitter's particles.
    ///   - swiftUIColor2: The final color for the emitter's particles.
    func setEvolvingColor(_ swiftUIColor1: SwiftUI.Color,
                          _ swiftUIColor2: SwiftUI.Color) {

        // Create two single color value instances.
        let color1 = ParticleEmitter.Color(swiftUIColor1)
        let color2 = ParticleEmitter.Color(swiftUIColor2)
        let singleColorValue1 = ParticleColorValue.single(color1)
        let singleColorValue2 = ParticleColorValue.single(color2)

        // Create an evolving color that shifts from one color value to another.
        let evolvingColor = ParticleColor.evolving(start: singleColorValue1,
                                                   end: singleColorValue2)

        // Change the particle color for the emitter.
        emitterComponent.mainEmitter.color = evolvingColor

        // Replace the entity's emitter component with the current configuration.
        emitterEntity.components.set(emitterComponent)
    }
    
    func setInheritColor() {
        emitterComponent.spawnInheritsParentColor = true
    }
}

extension ParticleEmitterComponent.EmitterShape: CaseIterable, Identifiable {
    public var id: Self { self }
    public static var allCases: [ParticleEmitterComponent.EmitterShape] = [
        .plane, .cylinder, .point
    ]
    var description: String {
        switch self {
            case .box: "box"
            case .point: "point"
            case .plane: "plane"
            case .sphere: "sphere"
            case .cone: "cone"
            case .cylinder: "cylinder"
            case .torus: "torus"
            @unknown default: "default"
        }
    }
}
