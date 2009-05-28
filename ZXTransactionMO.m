/*
 * Name: 	ZXTransactionMO.m
 * Project:	Strongbox
 * Created on:	2008-03-04
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

#import "ZXTransactionMO.h"
#import "ZXLabelController.h"
#import "ZXNotifications.h"
#import "ZXAppController.h"

static NSString *sharedNoLabelString = @"-";

@implementation ZXTransactionMO
@dynamic transactionLabelName;
@synthesize balance;

//! Forward method for transactionLabel.name
- (NSString *)transactionLabelName { return [self valueForKeyPath:@"transactionLabel.name"]; }

//! Action for label pop-up cell.
/*!
 Sets the transaction label of the transaction to the title of the sender
 */
- (IBAction)setTransactionLabelFromPopUp:(id)sender { [self setTransactionLabelName:[sender title]]; }

//! Sets new _label_ for transaction, based on name.
/*!
 Fetch the required label based on name, and sets new label for transaction.
 */
- (void)setTransactionLabelName:(NSString *)newLabelName
{
	if(!newLabelName) return;
	id labelDesc = [NSEntityDescription entityForName:@"Label" 
				   inManagedObjectContext:[self managedObjectContext]];
	NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"(name like %@)", newLabelName];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:labelDesc];
	[fetchRequest setPredicate:namePredicate];
	[fetchRequest setFetchLimit:1];
	NSError *error = nil;
	NSArray *array = [[self managedObjectContext] executeFetchRequest:fetchRequest 
								    error:&error];
	if(array == nil || [array count] < 1) {
		return;
	}
	[self setValue:[array objectAtIndex:0] forKey:@"transactionLabel"];
}

//! Initialization of the balance
/*! 
 Upon insertion, sets the balance of the new transaction to the current 
 balance of the account. 
 */
- (void)didChangeValueForKey:(NSString *)key
{
	[super didChangeValueForKey:key];
	if([key isEqual:@"account"]) {
		[self setValue:[self valueForKeyPath:@"account.balance"] 
			forKey:@"balance"];
	}
}

//! Initialization of the account
/*! 
 Sets current date and no-label.
 */
- (void)awakeFromInsert {
	[self setValue:[NSDate date] forKey:@"date"];
	[self setTransactionLabelName:sharedNoLabelString];
}

//! Controls special cases of key-value changes
/*!
 Posts a ZXAccountTotalDidChangeNotification upon amount change or date change 
 in transaction. Posts a ZXTransactionLabelDidChangeNotification if label did 
 change. The latter is useful for reports, while the former is useful for 
 various updating.
 */
- (void)setValue:(id)newValue forKey:(id)key
{
	[super setValue:newValue forKey:key];
	if(([key isEqual:@"amount"] || [key isEqual:@"date"]) && 
	   [ZXAppController shouldPostNotifications]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ZXAccountTotalDidChangeNotification 
								    object:nil];
	} else if([key isEqual:@"transactionLabel"] && 
		  [ZXAppController shouldPostNotifications]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ZXTransactionLabelDidChangeNotification 
								    object:self];
	}
}

- (void)dealloc
{
	[balance release];
	[super dealloc];
}


@end
