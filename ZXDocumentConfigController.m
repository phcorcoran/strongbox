/*
 * Name: 	ZXDocumentController.m
 * Project:	Strongbox
 * Created on:	2008-07-15
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

#import "ZXDocumentConfigController.h"
#import "ZXNotifications.h"
#import "ZXAccountController.h"

@interface ZXDocumentConfigController (Private)
- (void)setAccountSelection:(NSNotification *)note;
@end

@implementation ZXDocumentConfigController
//! Prepares content of the controller
/*!
 Fetches and sets content from saved data. Registers to set selection when 
 accountController is ready.
 */
- (void)prepareContent
{
	[super prepareContent];
	// FIXME: Check if that is necessary
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DocumentConfig" 
							    inManagedObjectContext:self.managedObjectContext];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:entityDescription];
	[fetchRequest setFetchLimit:1];
	NSError *error = nil;
	NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(array == nil) {
		return;
	}
	
	if([array count] < 1) {
		[self setContent:[self newObject]];
	} else {
		[self setContent:[array objectAtIndex:0]];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAccountSelection:) name:ZXAccountControllerDidLoadNotification object:nil];
}

//! Restores previously saved selection upon initialization
/*!
 Fetch the account by name and sets selection in accountController.
 */
- (void)setAccountSelection:(NSNotification *)note
{
	NSError *error;
	if(!accountController) return;
	[accountController fetchWithRequest:nil merge:NO error:&error];
	id arr = [accountController valueForKey:@"arrangedObjects"];

	id selectedAccount = nil;
	for(id account in arr) {
		if([[account valueForKey:@"name"] isEqual:[[self content] valueForKey:@"currentAccountName"]]) {
			selectedAccount = account;
			break;
		}
	}
	
	if(selectedAccount == nil) {
		return;
	}
	[accountController setSelectionIndexes:[NSIndexSet indexSet]]; // Clear selection
	[accountController addSelectedObjects:[NSArray arrayWithObject:selectedAccount]];
	[accountController updateGeneralMessage:nil];
}

- (void)updateCurrentAccountName
{
	[[self content] setValue:[accountController valueForKeyPath:@"selection.name"] forKey:@"currentAccountName"];
	[[accountController owner] updateChangeCount:NSChangeUndone];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}
@end
