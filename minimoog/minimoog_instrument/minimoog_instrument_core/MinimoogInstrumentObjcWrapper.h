//
//  MinimoogInstrumentObjcWrapper.h
//  MinimoogInstrumentObjcWrapper.h
//
//  Created by Yauheni Lychkouski on 10/6/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

@interface MinimoogInstrumentObjcWrapper : NSObject {
}

- (id)init;
- (BOOL)allocateRenderResourcesWithMusicalContext:(AUHostMusicalContextBlock) musicalContext
                                 outputEventBlock:(AUMIDIOutputEventBlock)    outputEventBlock
                              transportStateBlock:(AUHostTransportStateBlock) transportStateBlock;
- (void)deallocateRenderResources;
- (void)setParameter:(AUParameterAddress) address value:(AUValue) value;
- (AUValue)getParameter:(AUParameterAddress) address;
- (AUInternalRenderBlock)internalRenderBlock;

@end
