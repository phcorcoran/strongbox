//
//  ZXAccountMergeController.h
//  Strongbox
//
//  Created by Pierre-Hans on 17/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ZXAccountMergeController : NSObject {
	id owner;
	IBOutlet NSArrayController *mergeAccountController;
	IBOutlet NSWindow *mergeSheet;
	IBOutlet NSWindow *mergeProgressSheet;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSTextField *mergeMessage;
	NSNumber *progressCount;
	NSNumber *progressTotal;
}
- (IBAction)raiseMergeSheet:(id)sender;
- (IBAction)endMergeSheet:(id)sender;
- (IBAction)merge:(id)sender;
- (void)updateView:(id)sender;
@end
