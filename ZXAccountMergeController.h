//
//  ZXAccountMergeController.h
//  Strongbox
//
//  Created by Pierre-Hans on 17/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Controller for account merging
/*! 
 Merges two or more accounts together.
 */
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
//! Starts the merging routine
/*! 
 First step is raising the selection sheet, then merge, then exit.
 */
- (void)main;
- (IBAction)raiseMergeSheet:(id)sender;
- (IBAction)endMergeSheet:(id)sender;
- (IBAction)merge:(id)sender;

//! Merge current account with others
/*!
 Current account is updated during the operation, collecting all the transactions.
 All other accounts involved are removed.
 */
- (void)mergeAccount:(id)account withAccounts:(NSArray *)allAccounts;
- (void)updateView:(id)sender;
@end
