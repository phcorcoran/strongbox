/*
 * Name: 	ZXAccountController.m
 * Project:	Strongbox
 * Created on:	2008-06-03
 *
 * Copyright (C) 2008 Pierre-Hans Corcoran
 *
 * --------------------------------------------------------------------------
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License (version 2) as published 
 *  by the Free Software Foundation. This program is distributed in the 
 *  hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
 *  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 *  See the GNU General Public License for more details. You should have 
 *  received a copy of the GNU General Public License along with this 
 *  program; if not, write to the Free Software Foundation, Inc., 51 
 *  Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 * --------------------------------------------------------------------------
 */

#import "ZXAccountController.h"
#import "ZXAccountMO.h"
#import "ZXCurrencyFormatter.h"
#import "ZXDocument.h"
#import "ZXNotifications.h"
#import "ZXTransactionController.h"

@interface ZXAccountController (Private)
- (NSString *)uniqueNewName:(NSString *)newDesiredName;
- (void)updateUsedNames;
- (void)validatesNewAccountName:(NSNotification *)aNotification;
@end


@implementation ZXAccountController
@synthesize usedNames, generalMessage;

- (id)init
{
	if(self = [super init]) {
		self.usedNames = [NSMutableDictionary dictionary];
	}
	return self;
}

//! Prepares the content of the controller
/*!
 If there is no accounts, adds one. Registers to validate name change, and sets 
 up used names dictionary.
 \sa updateUsedNames, validatesNewAccountName:
 */
- (void)prepareContent
{
	[super prepareContent];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Account" 
					    inManagedObjectContext:self.managedObjectContext]];
	
	NSError *error = nil;
	NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(array == nil) {
		return;
	}
	if([array count] < 1) {
		[self add:self];
	}
	[self updateUsedNames];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(validatesNewAccountName:) name:ZXAccountNameDidChangeNotification object:nil];
}

//! Controls special cases of key-value changes
/*!
 Posts a ZXActiveAccountDidChangeNotification upon selection change.
 */
- (void)setValue:(id)newValue forKey:(id)key
{
	[super setValue:newValue forKey:key];
	if([key isEqual:@"selectionIndex"] || [key isEqual:@"selectionIndexes"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ZXActiveAccountDidChangeNotification object:self];
	}
}

//! Basic initialization
/*!
 Registers to recalculate balances of selection when account total changes.
 \sa recalculateBalance:
 */
- (void)awakeFromNib
{
	[super awakeFromNib];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recalculateBalance:) name:ZXAccountTotalDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGeneralMessage:) name:ZXAccountTotalDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGeneralMessage:) name:ZXActiveAccountDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGeneralMessage:) name:ZXAccountNameDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGeneralMessage:) name:ZXTransactionSelectionDidChangeNotification object:nil];
}

- (void)recalculateBalance:(NSNotification *)note
{
	if([self valueForKeyPath:@"selection.self"] != NSNoSelectionMarker) {
		[[self valueForKeyPath:@"selection.self"] recalculateBalance:note];
	}
}

//! Creates a new object
/*! 
 Sets up new name to hard-coded "New Account" (to fix)
 */
- (id)newObject
{
	id obj = [super newObject];
	// FIXME: Hard-coded english
	[obj specialSetName:[self uniqueNewName:@"New Account"]];
	[self.usedNames setValue:[obj objectID] forKey:[obj valueForKey:@"name"]];
	return obj;
}

//! Sets the name of the account in the notification to avoid conflicts.
/*! 
 This function changes the name of the account in the notification if there is
 a duplicate with existing labels.
 \param aNotification NSNotification containing the new account as object.
 \sa uniqueNewName:
 */
- (void)validatesNewAccountName:(NSNotification *)aNotification
{
	id obj = [aNotification object];
	if(![[self content] containsObject:obj]) return;
	[obj specialSetName:[self uniqueNewName:[obj valueForKey:@"name"]]];
	[self updateUsedNames];
}

//! Generates a non-conflicting name from given name
/*! 
 Returns a new name from the given so that no conflict arises inserting a new 
 account with that name. Appends a number after the name if already exists.
 \param newDesiredName String containing the desired name of the account.
 \return Same or modified name depending on if conflict was found. 
 */
- (NSString *)uniqueNewName:(NSString *)newDesiredName
{
	NSString *allowedName = newDesiredName;
	int counter = 1;
	while([self.usedNames valueForKey:allowedName]) {
		allowedName = [NSString stringWithFormat:@"%@ %d", newDesiredName, counter++];
	}
	return allowedName;
}

//! Updates the dictionary containing the used names
/*!
 Is an expensive method. Uses Core Data fetches to get used names and reconstruct
 the dictionary from scratch.
 */
- (void)updateUsedNames
{
	NSEntityDescription *desc = [NSEntityDescription entityForName:@"Account" 
						inManagedObjectContext:self.managedObjectContext];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:desc];
	
	NSError *error = nil;
	NSArray *allAccounts = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(allAccounts == nil) {
		return;
	}
	NSMutableDictionary *usedNamesDict = [NSMutableDictionary dictionaryWithCapacity:[allAccounts count]];
	for(id account in allAccounts) {
		if([account valueForKey:@"name"] == nil) continue;
		[usedNamesDict setValue:[account objectID] forKey:[account valueForKey:@"name"]];
	}
	self.usedNames = usedNamesDict;
}

- (IBAction)remove:(id)sender
{
	[super remove:sender];
	[self updateUsedNames];
}

- (void)updateGeneralMessage:(NSNotification *)note
{
	static BOOL infiniteLoopBreaker = YES;
	if([self valueForKeyPath:@"selection.self"] == NSNoSelectionMarker) {
		if(infiniteLoopBreaker) {
			infiniteLoopBreaker = NO;
			[[NSNotificationQueue defaultQueue] enqueueNotification:note postingStyle:NSPostWhenIdle];
		}
		return;
	}
	infiniteLoopBreaker = YES;
	
	id count, name;
	count = [self valueForKeyPath:@"selection.transactions.@count"];
	name = [self valueForKeyPath:@"selection.name"];
	if(note != nil && [[[owner transactionController] valueForKeyPath:@"selectionIndexes.count"] intValue] > 1) {
		id partial, sum;
		partial = [[owner transactionController] valueForKeyPath:@"selectionIndexes.count"];
		int intSum = [[[owner transactionController] valueForKeyPath:@"selectedObjects.@sum.deposit"] intValue] - [[[owner transactionController] valueForKeyPath:@"selectedObjects.@sum.withdrawal"] intValue];
		sum = [[ZXCurrencyFormatter currencyFormatter] stringFromNumber:[NSNumber numberWithInt:intSum]];
		// FIXME: Hard-coded english
		[self setValue:[NSString stringWithFormat:@"%@ of %@ transactions in %@. Subtotal: %@", partial, count, name, sum]
			forKey:@"generalMessage"];
	} else {
		id balance;
		balance = [self valueForKeyPath:@"selection.balance"];
		if(!balance) balance = [NSNumber numberWithInt:0];
		balance = [[ZXCurrencyFormatter currencyFormatter] stringFromNumber:balance];
		// FIXME: Hard-coded english
		[self setValue:[NSString stringWithFormat:@"%@ transactions in %@. Total: %@", count, name, balance]
			forKey:@"generalMessage"];
	}
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}
@end
