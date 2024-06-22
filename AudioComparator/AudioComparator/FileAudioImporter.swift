//
//  FileAudioImporter.swift
//  AudioComparator
//
//  Created by softwave on 17/06/24.
//

import SwiftUI

struct FileAudioImporter: View {
    
    @State private var isShowing = false
    
    @State private var error: Error?
    @Binding var url: URL?
    
    var body: some View {
        Button {
            isShowing.toggle()
        } label: {
            Image(systemName: "plus")
        }.fileImporter(isPresented: $isShowing, allowedContentTypes: [.audio]) { result in
            
            switch result {
            case .success(let url):
                self.url = url
            case .failure(let error):
                self.error = error
            }
        }
        .errorAlert(error: $error)
    }
}

#Preview {
    FileAudioImporter(url: .constant(nil))
}
