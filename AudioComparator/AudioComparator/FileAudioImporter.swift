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


extension View {
    func errorAlert(error: Binding<Error?>, buttonTitle: String = "OK") -> some View {
        let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
        return alert(isPresented: .constant(localizedAlertError != nil), error: localizedAlertError) { _ in
            Button(buttonTitle) {
                error.wrappedValue = nil
            }
        } message: { error in
            Text(error.recoverySuggestion ?? "")
        }
    }
}

struct LocalizedAlertError: LocalizedError {
    let underlyingError: LocalizedError
    var errorDescription: String? {
        underlyingError.errorDescription
    }
    var recoverySuggestion: String? {
        underlyingError.recoverySuggestion
    }

    init?(error: Error?) {
        guard let localizedError = error as? LocalizedError else { return nil }
        underlyingError = localizedError
    }
}
