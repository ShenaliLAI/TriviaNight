//
//  Trivia_LinkApp.swift
//  Trivia Link
//
//  Created by STUDENT on 2025-11-24.
//

import SwiftUI
import CoreData

@main
struct Trivia_LinkApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
