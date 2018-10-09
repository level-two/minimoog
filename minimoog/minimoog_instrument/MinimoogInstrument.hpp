//
//  MinimoogInstrument.hpp
//  Minimoog_instrument
//
//  Created by Yauheni Lychkouski on 10/9/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

#ifndef MinimoogInstrument_hpp
#define MinimoogInstrument_hpp

#import <AudioToolbox/AudioToolbox.h>
#import <algorithm>
#import "MinimoogInstrumentBase.hpp"

class MinimoogInstrument : public MinimoogInstrumentBase {
public:
    MinimoogInstrument();
    virtual ~MinimoogInstrument();
    
    virtual void  process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset);
    virtual void  startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration);
    virtual void  handleMIDIEvent(AUMIDIEvent const& midiEvent);
    virtual void  setParameter(long int address, float value);
    virtual float getParameter(long int address);
private:
};

#endif /* MinimoogInstrument_hpp */
