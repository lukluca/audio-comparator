//
//  AudioExtractor.swift
//  AudioComparator
//
//  Created by softwave on 20/06/24.
//

import AudioToolbox

struct AudioExtractor {
    
    private func getPropertySize(of audioFile: AudioFileID, propertyID: AudioFilePropertyID) throws -> UInt32 {
        var propertySize: UInt32 = 0
        var writable: UInt32 = 0
        let status = AudioFileGetPropertyInfo(audioFile, propertyID, &propertySize, &writable)
        
        guard status == noErr else {
            throw NSError(status: status)
        }
        
        return propertySize
    }
    
    private func getProperty(of audioFile: AudioFileID, propertyID: AudioFilePropertyID) throws -> Int64 {
        var propertySize = try getPropertySize(of: audioFile, propertyID: propertyID)
        var property: Int64 = 0
        let status = AudioFileGetProperty(audioFile, propertyID, &propertySize, &property)
        
        guard status == noErr else {
            throw NSError(status: status)
        }
        
        return property
    }
    
    func execute(from url: URL) throws -> [Int16] {
        var audioFile: AudioFileID?
        var status = AudioFileOpenURL(url as CFURL, .readPermission, 0, &audioFile)
        
        guard status == noErr else {
            throw NSError(status: status)
        }
        
        guard let audioFile else {
            throw AudioExtractor.ExtractorError.noAudioFile
        }
        
        let fileDataSize = try getProperty(of: audioFile, propertyID: kAudioFilePropertyAudioDataByteCount)
        
        guard status == noErr else {
            throw NSError(status: status)
        }
        
        var dataSize: UInt32 = UInt32(fileDataSize)
        
        let intDataSize = Int(dataSize)
        
        let theData: UnsafeMutableRawPointer = malloc(MemoryLayout<UInt8>.size * intDataSize)
        
        AudioFileReadBytes(audioFile, false, 0, &dataSize, theData)
        
        var propertySize = try getPropertySize(of: audioFile, propertyID: kAudioFilePropertyDataFormat)
        
        var mDataFormat = AudioStreamBasicDescription()
        status = AudioFileGetProperty(audioFile, kAudioFilePropertyDataFormat, &propertySize, &mDataFormat)
        
        AudioFileClose(audioFile)
        
        let start = theData.bindMemory(to: Int16.self, capacity: intDataSize)
        let buffer = UnsafeBufferPointer(start: start, count: intDataSize)
        
        // TODO: split for unit of time
        
        return Array(buffer)
    }
}

private extension NSError {
    convenience init(status: OSStatus) {
        self.init(domain: NSOSStatusErrorDomain, code: Int(status))
    }
}

extension AudioExtractor {
    enum ExtractorError: Error {
        case noAudioFile
    }
}
