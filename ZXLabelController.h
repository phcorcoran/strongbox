//
//  ZXLabelController.h
//  Cashbox
//
//  Created by Pierre-Hans on 30/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZXLabelMO.h"

static id sharedNoLabelObject = nil;

@interface ZXLabelController : NSArrayController {
	NSMutableDictionary *usedNames;
}
@property (assign) NSMutableDictionary *usedNames;
+ (id)noLabelObjectWithMOC:(NSManagedObjectContext *)moc;
- (void)validatesNewLabelName:(NSNotification *)aNotification;
- (NSString *)uniqueNewName:(NSString *)newDesiredName;
- (void)updateUsedNames;
@end
