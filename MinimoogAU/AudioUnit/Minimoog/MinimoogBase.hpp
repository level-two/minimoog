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

#ifndef MinimoogInstrumentBase_hpp
#define MinimoogInstrumentBase_hpp

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

class MinimoogBase {
public:
    MinimoogBase();
    virtual ~MinimoogBase();
    
    virtual void setParameter(AUParameterAddress address, AUValue value) = 0;
    virtual AUValue getParameter(AUParameterAddress address) = 0;
	virtual void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) = 0;
    virtual void handleMIDIEvent(AUMIDIEvent const& midiEvent) = 0;
    virtual void doRender(float *outL, float *outR) = 0;
    virtual bool doAllocateRenderResources() = 0;
    virtual void doDeallocateRenderResources() = 0;
    virtual void setSampleRate(float sr) = 0;
    
    bool allocateRenderResources(const AudioBufferList* audioBufferList);
    void deallocateRenderResources();
    
    void render(AudioUnitRenderActionFlags* actionFlags,
                const AudioTimeStamp*       timestamp,
                AUAudioFrameCount           frameCount,
                NSInteger                   outputBusNumber,
                AudioBufferList*            outputData,
                const AURenderEvent*        realtimeEventListHead,
                AURenderPullInputBlock      pullInputBlock);
    
private:
    void prepareOutputBufferList(AudioBufferList* outBufferList, AVAudioFrameCount frameCount, bool zeroFill);
    void renderSegmentFrames(AUAudioFrameCount frameCount, AudioBufferList*  outputData, AUAudioFrameCount const bufferOffset);
	void performAllSimultaneousEvents(AUEventSampleTime now, AURenderEvent const* &event);
    
protected:
    const AudioBufferList *m_audioBufferList;
};

#endif /* MinimoogInstrumentBase_hpp */
