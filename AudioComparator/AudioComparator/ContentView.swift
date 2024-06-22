//
//  ContentView.swift
//  AudioComparator
//
//  Created by softwave on 17/06/24.
//

import SwiftUI
import SwiftData
import CryptoKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [MusicFile]
    
    @State private var importedFile: URL?
    
    @State private var error: Error?

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { model in
                    NavigationLink {
                        MusicFileDetail.from(model: model)
                    } label: {
                        CellView.from(model: model)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    FileAudioImporter(url: $importedFile)
                }
            }
        } detail: {
            Text("Select an item")
        }
        .onChange(of: importedFile) { _, newValue in
            guard let newValue else {
                return
            }
            do {
                try add(url: newValue)
            } catch {
                self.error = error
            }
        }
        .onAppear {
            if ProcessInfo.processInfo.isPreview {
                loadFileFromBundle()
            }
            
            #if targetEnvironment(simulator)
                loadFileFromBundle()
            #endif
        }
        .errorAlert(error: $error)
    }
    
    private func loadFileFromBundle() {
        if let sound = Bundle.main.url(forResource: "town-10169", withExtension: "mp3") {
            importedFile = sound
        }
    }

    private func add(url: URL) throws {
        try withAnimation {
            let item = MusicFile(
                hashFile: try url.calculatedHash(),
                url: url,
                title: ""
            )
        
            modelContext.insert(item)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.forEach { index in
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: MusicFile.self, inMemory: true)
}

extension ProcessInfo {
    var isPreview: Bool {
        environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}


struct CellView: View {
    
    @Environment(\.modelContext) private var modelContext
    let model: MusicFile
    
    @StateObject var audioMetadata: AudioMetadata
    
    @State private var error: Error?
    
    var body: some View {
        HStack(spacing: 20) {
            
            Text(audioMetadata.title)
        }
        .errorAlert(error: $error)
        .task {
            do {
                try await audioMetadata.load()
                model.title = audioMetadata.title
            } catch {
                self.error = error
            }
        }
    }
}

extension CellView {
    static func from(model: MusicFile) -> Self {
        CellView(
            model: model,
            audioMetadata: AudioMetadata(url: model.url)
        )
    }
}

private extension URL {
    func calculatedHash() throws -> String {
        try sha256().map { String(format: "%02hhx", $0) }.joined()
    }
    
    private func sha256() throws -> SHA256.Digest {
        let handle = try FileHandle(forReadingFrom: self)
        var hasher = SHA256()
        while autoreleasepool(invoking: {
            let nextChunk = handle.readData(ofLength: SHA256.blockByteCount)
            guard !nextChunk.isEmpty else { return false }
            hasher.update(data: nextChunk)
            return true
        }) { }
        return hasher.finalize()
    }
}
