//
//  Bootcamp_HW_9App.swift
//  Bootcamp_HW_9
//
//  Created by Cuma Aktaş on 24.09.2025.
//

import SwiftUI
import CoreData

@main
struct CoreDataNotesApp: App {
    let persistence = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            Bootcamp_HW_9()
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
