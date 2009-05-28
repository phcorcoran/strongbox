/*
 * Name: 	ZXAccountMO.m
 * Project:	Strongbox
 * Created on:	2008-07-16
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

#import "ZXAccountMO.h"
#import "ZXTransactionMO.h"
#import "ZXNotification.h"

@implementation ZXAccountMO
@synthesize balance;

//! Posts a notification if name is changed
/*!
 Use specialSetName: to avoid notification posting.
 \sa specialSetName:
 */
- (void)setValue:(id)value forKey:(NSString *)key
{
	[super setValue:value forKey:key];
	if([key isEqual:@"name"]) {
		[ZXNotification postNotificationName:ZXAccountNameDidChangeNotification 
					      object:self];
	}
}

- (void)specialSetName:(NSString *)newName
{
	[super setValue:newName forKey:@"name"];
}

- (void)recalculateBalance:(NSNotification *)note
{
	id txDesc = [NSEntityDescription entityForName:@"Transaction" 
				inManagedObjectContext:[self managedObjectContext]];
	NSPredicate *balancePredicate = [NSPredicate predicateWithFormat: @"account == %@", self];
	id dateSort = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"date" 
									    ascending:YES] autorelease]];
	
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:txDesc];
	[fetchRequest setPredicate:balancePredicate];
	[fetchRequest setSortDescriptors:dateSort];
	NSError *error = nil;
	NSArray *array = [[self managedObjectContext] executeFetchRequest:fetchRequest 
								    error:&error];
	if(array == nil) {
		return;
	}
	
	double sum = 0;
	for(id obj in array) {
		double add = [[obj valueForKey:@"amount"] doubleValue];
		sum += add;
		[obj setValue:[NSNumber numberWithDouble:sum] forKey:@"balance"];
	}
	[self setValue:[NSNumber numberWithDouble:sum] forKey:@"balance"];
}

- (void)dealloc
{
	[balance release];
	[super dealloc];
}
@end
