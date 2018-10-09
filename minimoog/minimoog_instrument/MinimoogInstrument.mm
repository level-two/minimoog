//
//  MinimoogInstrument.cpp
//  Minimoog_instrument
//
//  Created by Yauheni Lychkouski on 10/9/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

#import "MinimoogInstrument.hpp"

MinimoogInstrument::MinimoogInstrument() {
    
}

MinimoogInstrument::~MinimoogInstrument() {
    
}

void MinimoogInstrument::setParameter(AUParameterAddress address, AUValue value) {
    switch (address) {
        case osc1RangeParamAddr:
            m_osc1Range = value;
            break;
        case osc1WaveformParamAddr:
            m_osc1Waveform = value;
            break;
        case osc2RangeParamAddr:
            m_osc2Range = value;
            break;
        case osc2DetuneParamAddr:
            m_osc2Detune = value;
            break;
        case osc2WaveformParamAddr:
            m_osc2Waveform = value;
            break;
        case mixOsc1VolumeParamAddr:
            m_mixOsc1Volume = value;
            break;
        case mixOsc2VolumeParamAddr:
            m_mixOsc2Volume = value;
            break;
        case mixNoiseVolumeParamAddr:
            m_mixNoiseVolume = value;
            break;
        default:
            break;
    }
}

AUValue MinimoogInstrument::getParameter(AUParameterAddress address) {
    AUValue val = 0;
    switch (address) {
        case osc1RangeParamAddr:
            val = m_osc1Range;
        case osc1WaveformParamAddr:
            val = m_osc1Waveform;
        case osc2RangeParamAddr:
            val = m_osc2Range;
        case osc2DetuneParamAddr:
            val = m_osc2Detune;
        case osc2WaveformParamAddr:
            val = m_osc2Waveform;
        case mixOsc1VolumeParamAddr:
            val = m_mixOsc1Volume;
        case mixOsc2VolumeParamAddr:
            val = m_mixOsc2Volume;
        case mixNoiseVolumeParamAddr:
            val = m_mixNoiseVolume;
    }
    return val;
}


void MinimoogInstrument::startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) {
    setParameter(address, value);
}


void MinimoogInstrument::handleMIDIEvent(AUMIDIEvent const& midiEvent)
{
    if (midiEvent.length != 3) return;
    uint8_t status = midiEvent.data[0] & 0xF0;
    //uint8_t channel = midiEvent.data[0] & 0x0F; // works in omni mode.
    switch (status) {
        case 0x80 : { // note off
            uint8_t note = midiEvent.data[1];
            if (note > 127) break;
            noteStates[note].noteOn(note, 0);
            break;
        }
        case 0x90 : { // note on
            uint8_t note = midiEvent.data[1];
            uint8_t veloc = midiEvent.data[2];
            if (note > 127 || veloc > 127) break;
            noteStates[note].noteOn(note, veloc);
            break;
        }
        case 0xB0 : { // control
            uint8_t num = midiEvent.data[1];
            if (num == 123) { // all notes off
                NoteState* noteState = playingNotes;
                while (noteState) {
                    noteState->clear();
                    noteState = noteState->next;
                }
                playingNotes = nullptr;
                playingNotesCount = 0;
            }
            break;
        }
    }
}

void MinimoogInstrument::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    
}



void MinimoogInstrument::generateNextSample(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    updateStates();
    generateSample();
}
