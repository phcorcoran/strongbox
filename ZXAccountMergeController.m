//
//  ZXAccountMergeController.m
//  Strongbox
//
//  Created by Pierre-Hans on 17/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ZXAccountMergeController.h"
#import "ZXAccountMO.h"
#import "ZXDocument.h"


@implementation ZXAccountMergeController
- (id)initWithOwner:(id)newOwner
{
	self = [super init];
	owner = newOwner;
	[NSBundle loadNibNamed:@"MergeWindow" owner:self];
	return self;
}

- (IBAction)raiseMergeSheet:(id)sender
{
	[NSApp beginSheet:mergeSheet 
	   modalForWindow:[owner strongboxWindow] 
	    modalDelegate:self 
	   didEndSelector:nil 
	      contextInfo:NULL];
}

- (IBAction)endMergeSheet:(id)sender
{
	[mergeSheet orderOut:sender];
	[NSApp endSheet:mergeSheet returnCode:1];
}

- (IBAction)merge:(id)sender
{
	[self endMergeSheet:self];
	[NSApp beginSheet:mergeProgressSheet 
	   modalForWindow:[owner strongboxWindow] 
	    modalDelegate:self 
	   didEndSelector:nil 
	      contextInfo:NULL];
	ZXAccountMO *current = [owner valueForKeyPath:@"accountController.selection.self"];
	[current mergeWithAccounts:[self valueForKeyPath:@"mergeAccountController.selectedObjects"]
			controller:self];
	[mergeProgressSheet orderOut:sender];
	[NSApp endSheet:mergeProgressSheet returnCode:1];
}

- (void)updateView:(id)sender
{
	// FIXME: Hard-coded english
	[mergeMessage setStringValue:[NSString stringWithFormat:@"Merging %@ of %@ transactions", progressCount, progressTotal]];
	[mergeProgressSheet display];
	[[owner strongboxWindow] display];
}
@end
