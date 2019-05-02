// -----------------------------------------------------------------------------
//    Copyright (C) 2018 Yauheni Lychkouski.
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
// -----------------------------------------------------------------------------

#import "Minimoog.hpp"
#import "GeneratorSine.hpp"
#import "GeneratorSquare.hpp"
#import "GeneratorSaw.hpp"

static inline double noteToHz(int noteNumber)
{
    return 440. * exp2((noteNumber - 69.)/12.);
}

static inline double detunedNoteToHz(int noteNumber, float cents)
{
    return 440. * exp2((noteNumber + cents/1200. - 69.)/12.);
}

Minimoog::Minimoog() {
    m_osc1Generator[0] = new GeneratorSaw(0.5);
    m_osc2Generator[0] = new GeneratorSaw(0.5);
    m_osc1Generator[1] = new GeneratorSine();
    m_osc2Generator[1] = new GeneratorSine();
    m_osc1Generator[2] = new GeneratorSaw(1.0);
    m_osc2Generator[2] = new GeneratorSaw(1.0);
    m_osc1Generator[3] = new GeneratorSquare(0.5);
    m_osc2Generator[3] = new GeneratorSquare(0.5);
    m_osc1Generator[4] = new GeneratorSquare(0.25);
    m_osc2Generator[4] = new GeneratorSquare(0.25);
    m_osc1Generator[5] = new GeneratorSquare(0.125);
    m_osc2Generator[5] = new GeneratorSquare(0.125);
    srand48(time(0));
}

Minimoog::~Minimoog() {
    for (int i = 0; i < 6; i++) {
        delete m_osc1Generator[i];
        delete m_osc2Generator[i];
    }
}

bool Minimoog::doAllocateRenderResources() {
    return true;
}

void Minimoog::doDeallocateRenderResources() {
    
}

void Minimoog::setParameter(AUParameterAddress address, AUValue value) {
    switch (address) {
        case osc1Range:
            assert(value >= 1 && value <= 6);
            m_osc1Range = value;
            updateOsc1State();
            break;
        case osc1Waveform:
            assert(value >= 1 && value <= 6);
            m_osc1Waveform = value;
            m_osc1SelectedGenerator = (int) value - 1;
            break;
        case osc2Range:
            assert(value >= 1 && value <= 6);
            m_osc2Range = value;
            updateOsc2State();
            break;
        case osc2Detune:
            assert(value >= -1200 && value <= 1200);
            m_osc2Detune = value;
            updateOsc2State();
            break;
        case osc2Waveform:
            assert(value >= 1 && value <= 6);
            m_osc2Waveform = value;
            m_osc2SelectedGenerator = (int) value - 1;
            break;
        case mixOsc1Volume:
            assert(value >= 0 && value <= 10);
            m_mixOsc1Volume = value;
            m_mixOsc1AmplMultiplier = value / 10.;
            break;
        case mixOsc2Volume:
            assert(value >= 0 && value <= 10);
            m_mixOsc2Volume = value;
            m_mixOsc2AmplMultiplier = value / 10.;
            break;
        case mixNoiseVolume:
            assert(value >= 0 && value <= 10);
            m_mixNoiseVolume = value;
            m_mixNoiseAmplMultiplier = value / 10.;
            break;
    }
}

AUValue Minimoog::getParameter(AUParameterAddress address) {
    AUValue val = 0;
    switch (address) {
        case osc1Range:
            val = m_osc1Range;
            break;
        case osc1Waveform:
            val = m_osc1Waveform;
            break;
        case osc2Range:
            val = m_osc2Range;
            break;
        case osc2Detune:
            val = m_osc2Detune;
            break;
        case osc2Waveform:
            val = m_osc2Waveform;
            break;
        case mixOsc1Volume:
            val = m_mixOsc1Volume;
            break;
        case mixOsc2Volume:
            val = m_mixOsc2Volume;
            break;
        case mixNoiseVolume:
            val = m_mixNoiseVolume;
            break;
    }
    return val;
}

void Minimoog::startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) {
    setParameter(address, value);
}

void Minimoog::handleMIDIEvent(AUMIDIEvent const& midiEvent)
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
            if (note == m_currentNote) {
                for (int i = 0; i < 6; i++) {
                    m_osc1Generator[i]->setAmplitude(0);
                    m_osc2Generator[i]->setAmplitude(0);
                }
                m_noiseAmpl = 0;
            }
            break;
        }
        case 0x90 : { // note on
            uint8_t note = midiEvent.data[1];
            uint8_t vel  = midiEvent.data[2];
            m_currentNote = note;
            for (int i = 0; i < 6; i++) {
                m_osc1Generator[i]->setAmplitude(vel / 127.);
                m_osc2Generator[i]->setAmplitude(vel / 127.);
            }
            m_noiseAmpl = vel / 127.;
            updateOsc1State();
            updateOsc2State();
            break;
        }
        case 0xb0 : { // control change
            uint8_t cc_num = midiEvent.data[1];
            if (cc_num == 0x7b) { // all notes off
                for (int i = 0; i < 6; i++) {
                    m_osc1Generator[i]->setAmplitude(0);
                    m_osc2Generator[i]->setAmplitude(0);
                }
                m_noiseAmpl = 0;
            }
            break;
        }
    }
}

void Minimoog::setSampleRate(float sr) {
    for (int i = 0; i < 6; i++) {
        m_osc1Generator[i]->setSampleRate(sr);
        m_osc2Generator[i]->setSampleRate(sr);
    }
}

void Minimoog::updateOsc1State() {
    float freqMultiplier = (m_osc1Range == 1) ? 1./128. : exp2f(m_osc1Range - 3.);
    float noteFrequency = freqMultiplier * noteToHz(m_currentNote);
    for (int i = 0; i < 6; i++) {
        m_osc1Generator[i]->setFrequency(noteFrequency);
    }
}


void Minimoog::updateOsc2State() {
    float freqMultiplier = (m_osc2Range == 1) ? 1./128. : exp2f(m_osc2Range - 3.);
    float noteFrequency = freqMultiplier * detunedNoteToHz(m_currentNote, m_osc2Detune);
    for (int i = 0; i < 6; i++) {
        m_osc2Generator[i]->setFrequency(noteFrequency);
    }
}

void Minimoog::doRender(float *outL, float *outR) {
    // OSC1
    float osc1Smpl;
    float osc1Smpr;
    m_osc1Generator[m_osc1SelectedGenerator]->render(&osc1Smpl, &osc1Smpr);
    
    // OSC2
    float osc2Smpl;
    float osc2Smpr;
    m_osc2Generator[m_osc1SelectedGenerator]->render(&osc2Smpl, &osc2Smpr);
    
    // NOISE
    float noiseSmp = m_noiseAmpl * ((float)drand48() * 2. - 1.);
    
    // MIX
    float mixSmpl =
        osc1Smpl  * m_mixOsc1AmplMultiplier +
        osc2Smpl  * m_mixOsc2AmplMultiplier +
        noiseSmp * m_mixNoiseAmplMultiplier;
    
    float mixSmpr =
        osc1Smpr  * m_mixOsc1AmplMultiplier +
        osc2Smpr  * m_mixOsc2AmplMultiplier +
        noiseSmp * m_mixNoiseAmplMultiplier;
    
    *outL = mixSmpl;
    *outR = mixSmpr;
}
