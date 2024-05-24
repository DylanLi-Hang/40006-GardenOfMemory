// This is for swift data preview, but not used since preview function is not good in visionOS.

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
