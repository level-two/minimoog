//
//  MinimoogInstrumentObjcWrapper.h
//  MinimoogInstrumentObjcWrapper.h
//
//  Created by Yauheni Lychkouski on 10/6/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface MinimoogInstrumentObjcWrapper : NSObject {
}

- (id)init;
- (id)initWithAudioFormat:(AVAudioFormat*)audioFormat maxChannels:(AVAudioChannelCount) maxChannels;
- (BOOL)allocateRenderResourcesWithMusicalContext:(AUHostMusicalContextBlock) musicalContext
                                 outputEventBlock:(AUMIDIOutputEventBlock)    outputEventBlock
                              transportStateBlock:(AUHostTransportStateBlock) transportStateBlock
                                        maxFrames:(AVAudioFrameCount)         maxFrames;
- (void)deallocateRenderResources;
- (void)setParameter:(AUParameterAddress) address value:(AUValue) value;
- (AUValue)getParameter:(AUParameterAddress) address;
- (void)setSampleRate:(double)sampleRate;
- (AUInternalRenderBlock)internalRenderBlock;

@end
