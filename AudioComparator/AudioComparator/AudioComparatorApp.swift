//
//  AudioComparatorApp.swift
//  AudioComparator
//
//  Created by softwave on 17/06/24.
//

import SwiftUI
import SwiftData
import SpectrogramView

@main
struct AudioComparatorApp: App {
    
    /*
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MusicFile.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
     */

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            MusicFile.self
        ])
    }
}
