//
//  MusicFileDetail.swift
//  AudioComparator
//
//  Created by softwave on 19/06/24.
//

import SwiftUI
import SpectrogramView

struct MusicFileDetail: View {
    
    @StateObject private var audioSpectrogram = AudioSpectrogram()
    
    let model: MusicFile
    
    @StateObject var audioPlayerViewModel: AudioPlayerViewModel
    
    @State private var error: Error?
    
    var body: some View {
        
        VStack {
            Text(model.title)
            
            HStack {
                
                Button(action: {
                    do {
                        try audioPlayerViewModel.playOrPause()
                    } catch {
                        self.error = error
                    }
                }) {
                    Image(systemName: audioPlayerViewModel.isPlaying ? "pause.circle" : "play.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                    Text(audioPlayerViewModel.isPlaying ? "Pause music" : "Start music")
                }
                
                Button(action: {
                    do {
                        let rawAudioData = try AudioExtractor().execute(from: model.url)
                        audioSpectrogram.rawAudioData = rawAudioData
                        audioSpectrogram.startRunning()
                        audioSpectrogram.rawAudioData.removeAll()
                    } catch {
                        self.error = error
                    }
                }) {
                    HStack {
                        Text("Start draw")
                    }
                }
            }
            
            if let image = audioSpectrogram.outputImage {
                Image(decorative: image,
                      scale: 1,
                      orientation: .left)
                .resizable()
            }
        }
        .onAppear {
            audioSpectrogram.configuation = .init(requiresMicrophone: false)
        }
        .onChange(of: audioSpectrogram.error) { error in
            self.error = error
        }
        .errorAlert(error: $error)
    }
}


extension MusicFileDetail {
    static func from(model: MusicFile) -> Self {
        MusicFileDetail(
            model: model,
            audioPlayerViewModel: AudioPlayerViewModel(url: model.url)
        )
    }
}

#Preview {
    MusicFileDetail(
        model: MusicFile(hashFile: "has", url: URL(string: "www.url.com")!, title: "beautifull"),
        audioPlayerViewModel: AudioPlayerViewModel(url: URL(string: "www.url.com")!)
    )
}
