//
//  AudioPlayerViewModel.swift
//  AudioComparator
//
//  Created by softwave on 17/06/24.
//

import AVFoundation

final class AudioPlayerViewModel: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    
    @Published var isPlaying = false
    
    private var error: Error?
    
    init(url: URL) {
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: url.path()))
        } catch {
            self.error = error
        }
    }
    
    func playOrPause() throws {
        guard let audioPlayer else {
            if let error {
                throw error
            }
            return
        }
        
        if audioPlayer.isPlaying {
            audioPlayer.pause()
            isPlaying = false
        } else {
            audioPlayer.play()
            isPlaying = true
        }
    }
}

final class AudioMetadata: ObservableObject {
    
    private let asset: AVURLAsset
    
    @Published var title: String = ""
    
    init(url: URL) {
        asset = AVURLAsset(url: url)
    }
    
    func load() async throws {
        
        let metadata = try await asset.load(.metadata)
        
        // Find the title in the common key space.
        let titleItems = AVMetadataItem.metadataItems(from: metadata,
                                                      filteredByIdentifier: .commonIdentifierTitle)
        
        if let title = titleItems.first {
            if let title = try await title.load(.stringValue) {
                await setTitle(title)
            } else {
                await setDefault()
            }
        } else {
            await setDefault()
        }
    }
    
    @MainActor
    private func setDefault() {
        setTitle(asset.url.lastPathComponent)
    }
    
    @MainActor
    private func setTitle(_ value: String) {
        title = value
    }
}

