//
//  MinimoogInstrument.cpp
//  Minimoog_instrument
//
//  Created by Yauheni Lychkouski on 10/9/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

#import "MinimoogInstrument.hpp"


static inline double noteToHz(int noteNumber)
{
    return 440. * exp2((noteNumber - 69.)/12.);
}

static inline double detunedNoteToHz(int noteNumber, float cents)
{
    return 440. * exp2((noteNumber + cents/8. - 69.)/12.);
}


MinimoogInstrument::MinimoogInstrument() {
    srand48(time(0));
}

MinimoogInstrument::~MinimoogInstrument() {
    
}


bool MinimoogInstrument::doAllocateRenderResources() {
    return true;
}

void MinimoogInstrument::doDeallocateRenderResources() {
    
}

void MinimoogInstrument::setParameter(AUParameterAddress address, AUValue value) {
    switch (address) {
        case osc1RangeParamAddr:
            m_osc1Range = value;
            updateOsc1State();
            break;
        case osc1WaveformParamAddr:
            m_osc1Waveform = value;
            break;
        case osc2RangeParamAddr:
            m_osc2Range = value;
            updateOsc2State();
            break;
        case osc2DetuneParamAddr:
            m_osc2Detune = value;
            updateOsc2State();
            break;
        case osc2WaveformParamAddr:
            m_osc2Waveform = value;
            break;
        case mixOsc1VolumeParamAddr:
            m_mixOsc1Volume = value;
            m_mixOsc1AmplMultiplier = value / 10.;
            break;
        case mixOsc2VolumeParamAddr:
            m_mixOsc2Volume = value;
            m_mixOsc2AmplMultiplier = value / 10.;
            break;
        case mixNoiseVolumeParamAddr:
            m_mixNoiseVolume = value;
            m_mixNoiseAmplMultiplier = value / 10.;
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
    // Check whether this is channel message and it has correct format
    if (midiEvent.length != 3 ||
       (midiEvent.data[0] & 0x80) == 0 ||
       (midiEvent.data[1] & 0x80) != 0 ||
       (midiEvent.data[2] & 0x80) != 0) return;
    
    uint8_t status  = midiEvent.data[0] & 0xf0;
    uint8_t channel = midiEvent.data[0] & 0x0f; // works in omni mode
    
    switch (status) {
        case 0x80 : { // note off
            uint8_t note = midiEvent.data[1];
            uint8_t vel  = midiEvent.data[2];
            m_osc1Ampl  = 0;
            m_osc2Ampl  = 0;
            m_noiseAmpl = 0;
            break;
        }
        case 0x90 : { // note on
            uint8_t note = midiEvent.data[1];
            m_currentNote = note;
            uint8_t vel  = midiEvent.data[2];
            m_osc1Ampl  = vel / 127.;
            m_osc2Ampl  = vel / 127.;
            m_noiseAmpl = vel / 127.;
            updateOsc1State();
            updateOsc2State();
            break;
        }
        case 0xb0 : { // control change
            uint8_t cc_num = midiEvent.data[1];
            if (cc_num == 0x7b) { // all notes off
                m_osc1Ampl  = 0;
                m_osc2Ampl  = 0;
                m_noiseAmpl = 0;
            }
            break;
        }
    }
}


void MinimoogInstrument::updateOsc1State() {
    m_osc1Freq = noteToHz(m_currentNote);
    m_osc1FreqMultiplier = (m_osc1Range == 0) ? 1./128. : exp2f(m_osc1Range - 2.);
}


void MinimoogInstrument::updateOsc2State() {
    m_osc2Freq = detunedNoteToHz(m_currentNote, m_osc2Detune);
    m_osc2FreqMultiplier = (m_osc2Range == 0) ? 1./128. : exp2f(m_osc2Range - 2.);
}


void MinimoogInstrument::doRender(float *outL, float *outR) {
    // OSC1
    m_osc1Phase += 2.*M_PI * m_osc1Freq * m_osc1FreqMultiplier / m_sampleRate;
    if (m_osc1Phase > 2.*M_PI) m_osc1Phase -= 2.*M_PI;
    float osc1Smp = m_osc1Ampl * sin(m_osc1Phase);
    
    // OSC2
    m_osc2Phase += 2.*M_PI * m_osc2Freq * m_osc2FreqMultiplier / m_sampleRate;
    if (m_osc2Phase > 2.*M_PI) m_osc2Phase -= 2.*M_PI;
    float osc2Smp = m_osc2Ampl * sin(m_osc2Phase);
    
    // NOISE
    float noiseSmp = (float)drand48() * 2. - 1.;
    // MIX
    
    float mixSmp =
        osc1Smp  * m_mixOsc1AmplMultiplier +
        osc2Smp  * m_mixOsc2AmplMultiplier +
        noiseSmp * m_mixNoiseAmplMultiplier;
    
    *outL = mixSmp;
    *outR = mixSmp;
}
