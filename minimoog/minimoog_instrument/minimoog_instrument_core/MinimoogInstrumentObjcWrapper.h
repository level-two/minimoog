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
