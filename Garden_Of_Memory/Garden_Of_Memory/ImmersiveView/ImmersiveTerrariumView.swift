//
//  ImmersiveTerrariumView.swift
//  Garden_Of_Memory
//
//  Created by Yu Ching Wong on 10/4/2024.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveTerrariumView: View {
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    @Environment(\.openImmersiveSpace) var openImmersiveTerrarium
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveTerrarium
    
//    @State var avatarView = false
    @State var terrarium = true
    
    private func create3DView () -> Entity? {
    //Create Sphere
    let sphere = MeshResource.generateSphere(radius: 1000)
    //Add material
    var material = UnlitMaterial()
    //Add texture
    do {
    let texture = try TextureResource.load(named: "sunny-immersive")
    material.color = .init(texture: .init(texture))
    } catch
    {
    }
    let myEntity = Entity()
    myEntity.components.set(ModelComponent(mesh: sphere, materials: [material]))
    myEntity.scale *= .init(x: -1, y: 1, z: 1)
    return myEntity
    }
    
    
    var body: some View {
        RealityView { content in
        guard let myEntity = create3DView() else {return}
        content.add(myEntity)
        print("ViewOpen")
        }
        VStack{
           
        }
    }
}

#Preview {
    ImmersiveTerrariumView()
}
