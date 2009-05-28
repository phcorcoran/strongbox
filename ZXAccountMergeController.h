/*
 * Name: 	ZXAccountMergeController.h
 * Project:	Strongbox
 * Created on:	2009-01-17
 *
 * Copyright (C) 2008 Pierre-Hans Corcoran
 *
 * --------------------------------------------------------------------------
 *  This program is  free software;  you can redistribute  it and/or modify it
 *  under the terms of the GNU General Public License (version 2) as published 
 *  by  the  Free Software Foundation.  This  program  is  distributed  in the 
 *  hope  that it will be useful,  but WITHOUT ANY WARRANTY;  without even the 
 *  implied warranty of MERCHANTABILITY  or  FITNESS FOR A PARTICULAR PURPOSE.  
 *  See  the  GNU General Public License  for  more  details.  You should have 
 *  received  a  copy  of  the  GNU General Public License   along  with  this 
 *  program;   if  not,  write  to  the  Free  Software  Foundation,  Inc., 51 
 *  Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 * --------------------------------------------------------------------------
 */

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
