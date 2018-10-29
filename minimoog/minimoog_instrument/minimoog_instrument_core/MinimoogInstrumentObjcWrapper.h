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

@property (nonatomic, retain) AUHostMusicalContextBlock *musicalContext;
@property (nonatomic, retain) AUMIDIOutputEventBlock    *outputEventBlock;
@property (nonatomic, retain) AUHostTransportStateBlock *transportStateBlock;


- (id)init;
- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError;
- (void)deallocateRenderResources;
- (void)setParameter:(AUParameterAddress) address value:(AUValue) value;
- (AUValue)getParameter:(AUParameterAddress) address;
- (AUInternalRenderBlock)internalRenderBlock;

@end
