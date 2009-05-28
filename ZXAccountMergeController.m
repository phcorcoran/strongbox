/*
 * Name: 	ZXAccountMergeController.m
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

#import "ZXAccountMergeController.h"
#import "ZXAccountMO.h"
#import "ZXDocument.h"
#import "ZXNotification.h"


@implementation ZXAccountMergeController
- (id)initWithOwner:(id)newOwner
{
	self = [super init];
	owner = newOwner;
	[NSBundle loadNibNamed:@"MergeWindow" owner:self];
	[progressIndicator setUsesThreadedAnimation:YES];
	return self;
}

- (void)main
{
	[self raiseMergeSheet:self];
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
	id current = [owner valueForKeyPath:@"accountController.selection.self"];
	[self mergeAccount:current
	      withAccounts:[self valueForKeyPath:@"mergeAccountController.selectedObjects"]];
	[mergeProgressSheet orderOut:sender];
	[NSApp endSheet:mergeProgressSheet returnCode:1];
}

- (void)mergeAccount:(id)account withAccounts:(NSArray *)allAccounts
{
	BOOL toRestore = [ZXNotification shouldPostNotifications];
	[ZXNotification setShouldPostNotifications:NO];
	
	id moc = [owner managedObjectContext];
	
	NSMutableArray *newAccounts = [allAccounts mutableCopy];
	id accDesc = [NSEntityDescription entityForName:@"Transaction" 
				 inManagedObjectContext:moc];
	
	[newAccounts removeObjectIdenticalTo:account];
	
	id pred = [NSPredicate predicateWithFormat:@"account IN %@", newAccounts];
	
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:accDesc];
	[fetchRequest setPredicate:pred];
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:fetchRequest error:&error];
	if(array == nil) {
		return;
	}
	[self setValue:[NSNumber numberWithInt:[array count]] 
		forKey:@"progressTotal"];
	[self setValue:[NSNumber numberWithInt:0] 
		forKey:@"progressCount"];
	// This may seem convoluted, but the overhead of setting the account
	// property directly to the new account is unexplainably high.
	// Instead, we remove the tx from old account and add it to a list
	// then we set the new account without triggering any action
	// then we set the new list as the transactions of the new account
	// In my case, the difference on 600 txs was from ~30s to ~1s for a merge.
	int i = 0;
	id tmp = [[[account valueForKey:@"transactions"] mutableCopy] autorelease];
	if(!tmp) return;
	for(id tx in array) {
		if(i % 100 == 0) {
			[self setValue:[NSNumber numberWithInt:i] 
				forKey:@"progressCount"];
			[self updateView:self];
		}
		[tx setValue:nil forKey:@"account"];
		[tx setPrimitiveValue:account forKey:@"account"];
		[tmp addObject:tx];
		i += 1;
	}
	[account setValue:tmp forKey:@"transactions"];
	[self updateView:self];
	for(id acc in newAccounts) {
		if(acc == self) continue;
		[moc deleteObject:acc];
	}
	[ZXNotification setShouldPostNotifications:toRestore];
	[ZXNotification postNotificationName:ZXAccountTotalDidChangeNotification 
				      object:self];
}


- (void)updateView:(id)sender
{
	// FIXME: Hard-coded english
	id message = [NSString stringWithFormat:@"Merging %@ of %@ transactions", progressCount, progressTotal];
	[mergeMessage setStringValue:message];
	[mergeProgressSheet displayIfNeeded];
}
@end
