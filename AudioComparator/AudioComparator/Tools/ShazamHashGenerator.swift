//
//  ShazamHashGenerator.swift
//  ParoleFuoriDalComune
//
//  Created by softwave on 12/06/24.
//

import Foundation
import Accelerate
import ComplexModule

struct ShazamHashGenerator {
    
    private let range: [Int] = [40, 80, 120, 180, 300]
    private let fuz_factor = 2
    
    func getHash(from data: [Int16]) -> Int {
        let transform = performFourierTransform(on: data)
        return getHash(from: transform)
    }
    
    private func getRangeIndex(of frequency: Int) -> Int {
        var i = 0
        while (range[i] < frequency) {
            i+=1
        }
        return i
    }
    
    private func performFourierTransform(on data: [Int16]) -> [Complex<Float>]{
        
        let signal = data.map { element in
            DSPComplex(real: Float(element), imag: 0)
        }
        
        let complexValuesCount = signal.count

        var splitSignalReal = [Float](repeating: 0,
                                      count: complexValuesCount)
        var splitSignalImag = [Float](repeating: 0,
                                      count: complexValuesCount)


        signal.withUnsafeBufferPointer { signalPtr in
            splitSignalReal.withUnsafeMutableBufferPointer { signalRealPtr in
                splitSignalImag.withUnsafeMutableBufferPointer { signalImagPtr in
                    var splitComplex = DSPSplitComplex(realp: signalRealPtr.baseAddress!,
                                                       imagp: signalImagPtr.baseAddress!)
                    
                    vDSP_ctoz(signalPtr.baseAddress!, 2,
                              &splitComplex, 1,
                              vDSP_Length(complexValuesCount))
                }
            }
        }
        
        var splitOutputReal = [Float](repeating: 0,
                                      count: complexValuesCount)
        var splitOutputImag = [Float](repeating: 0,
                                      count: complexValuesCount)


        if let splitComplexSetup = vDSP_DFT_zop_CreateSetup(nil,
                                                            vDSP_Length(complexValuesCount),
                                                            .FORWARD) {
            
            vDSP_DFT_Execute(splitComplexSetup,
                             splitSignalReal, splitSignalImag,
                             &splitOutputReal, &splitOutputImag)
            
            vDSP_DFT_DestroySetup(splitComplexSetup)
        }
        
        return splitOutputReal.enumerated().map { (index, real) in
            Complex(real, splitOutputImag[index])
        }
    }
    
    private func getHash(from complexes: [Complex<Float>]) -> Int {
        
        var highScores = Array<Float>(repeating: 0, count: range.count)
        var points = Array(repeating: 0, count: range.count)
        
        (40...300).forEach { freq in
    
            let magnitued = log(complexes[freq].length + 1)
            
            let index = getRangeIndex(of: freq)
            
            if magnitued > highScores[index] {
                highScores[index] = magnitued
                points[index] = freq
            }
        }
        
        return hash(p1: points[0], p2: points[1], p3: points[2], p4: points[3])
    }
    
    private func hash(p1: Int, p2: Int, p3: Int, p4: Int) -> Int {
        
        func scale(value: Int, factor: Int) -> Int {
            (value - (value % fuz_factor)) * factor
        }
        
        return scale(value: p4, factor: 100000000)
                + scale(value: p3, factor: 100000)
                + scale(value: p2, factor: 100)
                + scale(value: p1, factor: 1)
    }
}
