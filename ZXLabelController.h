//
//  ZXLabelController.h
//  Cashbox
//
//  Created by Pierre-Hans on 30/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZXLabelMO.h"

@class ZXLabelMO;
@interface ZXLabelController : NSArrayController {
	NSMutableDictionary *usedNames;
	ZXLabelMO *noLabel;
}
@property (assign) NSMutableDictionary *usedNames;
@property (retain) ZXLabelMO *noLabel;
- (void)validatesNewLabelName:(NSNotification *)aNotification;
- (NSString *)uniqueNewName:(NSString *)newDesiredName;
- (void)updateUsedNames;
- (void)setupNoLabelObject;
@end
