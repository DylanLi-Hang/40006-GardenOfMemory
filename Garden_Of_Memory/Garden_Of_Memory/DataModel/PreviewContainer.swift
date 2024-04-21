import Foundation
import SwiftData

class PreviewContainer {
    let container: ModelContainer!
    
    init(_ types: [any PersistentModel.Type], isStoredInMemoryOnly: Bool = false) {
        let schema = Schema(types)
        let config = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly)
        self.container = try! ModelContainer(for: schema, configurations: [config])
    }
    
    func add<T: PersistentModel>(items: [T]) {
        Task { @MainActor in
            items.forEach { container.mainContext.insert($0) }
        }
    }
}
