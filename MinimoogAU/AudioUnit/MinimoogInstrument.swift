//
//  MinimoogInstrument.swift
//  MinimoogAU
//
//  Created by Yauheni Lychkouski on 10/1/19.
//  Copyright © 2019 Yauheni Lychkouski. All rights reserved.
//

import Foundation
import AVFoundation

class MinimoogInstrument {

    init(with audioFormat:AVAudioFormat) {
        self.audioFormat = audioFormat
        // TODO instrument.setSampleRate(audioFormat.sampleRate)
    }

    func allocateRenderResources(musicalContext: @escaping AUHostMusicalContextBlock,
                                 outputEventBlock: @escaping AUMIDIOutputEventBlock,
                                 transportStateBlock: @escaping AUHostTransportStateBlock,
                                 maxFrames: AVAudioFrameCount) -> Bool {
        self.musicalContext = musicalContext
        self.outputEvent = outputEventBlock
        self.transportState = transportStateBlock
        if let pcmBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: maxFrames) {
            self.pcmBuffer = pcmBuffer
//            self.audioBufferList = pcmBuffer.audioBufferList // TODO Check this
        }
        return true
        // TODO return instrument.allocateRenderResources(audioBufferList)
    }

    func deallocateRenderResources() {
        musicalContext = nil
        outputEvent = nil
        transportState = nil
        pcmBuffer = nil
        //audioBufferList = nil
        // TODO instrument.deallocateRenderResources()
    }

    func setParameter(address: AUParameterAddress, value: AUValue) {
        // TODO instrument.setParameter(address, value)
    }

    func getParameter(address: AUParameterAddress) -> AUValue {
        return 0
        // TODO return instrument.getParameter(address)
    }

    func internalRenderBlock() -> AUInternalRenderBlock {
        return { [weak self] (actionFlags, timestamp, frameCount, outputBusNumber, outputData, realtimeEventListHead, pullInputBlock) -> AUAudioUnitStatus in
            guard let self = self else { return noErr }

            if let context = self.musicalContext {
                var currentTempo: Double = 0
                var timeSignatureNumerator: Double = 0
                var timeSignatureDenominator: Int = 0
                var currentBeatPosition: Double = 0
                var sampleOffsetToNextBeat: Int = 0
                var currentMeasureDownbeatPosition: Double = 0

                if context(&currentTempo, &timeSignatureNumerator, &timeSignatureDenominator, &currentBeatPosition, &sampleOffsetToNextBeat, &currentMeasureDownbeatPosition) {
                    // TODO self.minimoog.setTempo(currentTempo)
                    if self.transportStateIsMoving {
                        //NSLog(@"currentBeatPosition %f", currentBeatPosition)
                        // these two seem to always be 0. Probably a host issue.
                        //NSLog(@"sampleOffsetToNextBeat %ld", (long)sampleOffsetToNextBeat)
                        //NSLog(@"currentMeasureDownbeatPosition %f", currentMeasureDownbeatPosition)
                    }
                }
            }

            if let transportState = self.transportState {
                var flags: AUHostTransportStateFlags = .changed
                var currentSamplePosition: Double = 0
                var cycleStartBeatPosition: Double = 0
                var cycleEndBeatPosition: Double = 0

                if transportState(&flags, &currentSamplePosition, &cycleStartBeatPosition, &cycleEndBeatPosition) {
                    self.transportStateIsMoving = (flags == .moving)
                }
            }

            // TODO self.minimoog.render(actionFlags, timestamp, frameCount, outputBusNumber, outputData, realtimeEventListHead, pullInputBlock)
            return noErr
        }
    }

    fileprivate var musicalContext: AUHostMusicalContextBlock?
    fileprivate var transportState: AUHostTransportStateBlock?
    fileprivate var outputEvent: AUMIDIOutputEventBlock?

    fileprivate var audioFormat: AVAudioFormat
    fileprivate var pcmBuffer: AVAudioPCMBuffer?
//    fileprivate var audioBufferList: UnsafePointer<AudioBufferList>
    fileprivate var transportStateIsMoving: Bool = false
}
