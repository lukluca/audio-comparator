//
//  MusicFile.swift
//  AudioComparator
//
//  Created by softwave on 17/06/24.
//

import Foundation
import SwiftData

@Model
final class MusicFile {
    @Attribute(.unique) var hashFile: String
    var url: URL
    var title: String
    
    init(hashFile: String, url: URL, title: String) {
        self.hashFile = hashFile
        self.url = url
        self.title = title
    }
}
