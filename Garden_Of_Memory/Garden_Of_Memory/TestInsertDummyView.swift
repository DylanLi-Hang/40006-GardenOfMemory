//
//  TestDummyDataView.swift
//  Garden_Of_Memory
//
//  Created by Dylan on 2/4/2024.
//

import SwiftUI
import SwiftData

struct TestInsertDummyView: View {
    @Environment(\.modelContext) var modelContext
    var body: some View {
        Button {
            let dummyChat: ChatEntry = generateDummyChat()
            modelContext.insert(dummyChat)
        } label: {
            Text("Insert Dummy Data")
        }
        
    }
}

#Preview {
    TestInsertDummyView()
}
