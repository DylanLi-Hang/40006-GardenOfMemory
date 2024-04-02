import Foundation
import SwiftData

class PreviewContainer {
    let container: ModelContainer! // register the container
    
    init(_ types: [any PersistentModel.Type], isStoredInMemoryOnly: Bool = true) {
        let schema = Schema(types) // should be able to pass in any schema & have them registered
        let config = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly)
        self.container = try! ModelContainer(for: schema, configurations: [config])
    }
    
    func add(items: [any PersistentModel]) {
        Task { @MainActor in
            items.forEach {container.mainContext.insert($0)}
        }
    }
}
