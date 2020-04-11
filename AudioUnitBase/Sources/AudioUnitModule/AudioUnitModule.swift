//
//  AudioUnitModule.swift
//  AudioUnitBase
//
//  Created by Yauheni Lychkouski on 4/10/20.
//  Copyright © 2020 Yauheni Lychkouski. All rights reserved.
//

import Foundation

open class AudioUnitModule {
    public var samplesNumber: Int = 0
    public var sampleRate: Float32 = 0
    public private(set) var audioInputs = [Buffer]()
    public private(set) var cvInputs = [Buffer]()
    public var audioOutput: Buffer?
    public var cvOutput: Buffer?

    var audioOutputConnected: Bool {
        return outputAudioConnections.count > 0
    }

    var cvOutputConnected: Bool {
        return outputAudioConnections.count > 0
    }

    func connectAudioInput(to otherModule: AudioUnitModule) {
        inputAudioConnections.append(otherModule)
        otherModule.outputAudioConnections.append(Weak(self))
    }

    func connectCvInput(to otherModule: AudioUnitModule) {
        inputCvConnections.append(otherModule)
        otherModule.outputCvConnections.append(Weak(self))
    }

    public func allocateRenderResources(_ sampleRate: Float32, _ samplesNumber: Int) {
        guard !isAllocated else { return }

        isAllocated = true

        self.sampleRate = sampleRate
        self.samplesNumber = samplesNumber

        if audioOutputConnected {
            audioOutput = Buffer.allocate(capacity: samplesNumber)
        }

        if cvOutputConnected {
            cvOutput = Buffer.allocate(capacity: samplesNumber)
        }

        inputAudioConnections.forEach { $0.allocateRenderResources(sampleRate, samplesNumber) }
        inputCvConnections.forEach { $0.allocateRenderResources(sampleRate, samplesNumber) }

        audioInputs = inputAudioConnections.compactMap { $0.audioOutput }
        cvInputs = inputCvConnections.compactMap { $0.cvOutput }
    }

    public func deallocateRenderResources() {
        audioOutput?.deallocate()
        cvOutput?.deallocate()
        audioOutput = nil
        cvOutput = nil
        audioInputs = []
        cvInputs = []
        renderRequests = 0
        isAllocated = false
    }

    open func doRender() {
        // TBD: Fill outputs with rendered samples
    }

    deinit {
        deallocateRenderResources()
        print("🔥")
    }

    private var inputAudioConnections = [AudioUnitModule]()
    private var inputCvConnections = [AudioUnitModule]()
    private var outputAudioConnections = [Weak<AudioUnitModule>]()
    private var outputCvConnections = [Weak<AudioUnitModule>]()
    private var renderRequests = 0
    private var isAllocated = false
}

fileprivate extension AudioUnitModule {
    func render() {
        if renderRequests == 0 {
            inputAudioConnections.forEach { $0.render() }
            inputCvConnections.forEach { $0.render() }
            doRender()
        }
        renderRequests += 1
        if renderRequests == outputAudioConnections.count + outputCvConnections.count {
            renderRequests = 0
        }
    }
}
