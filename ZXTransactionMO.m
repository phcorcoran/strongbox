/*
 * Name: 	ZXTransactionMO.m
 * Project:	Cashbox
 * Created on:	2008-03-04
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

#import "ZXTransactionMO.h"


@implementation ZXTransactionMO

@dynamic transactionLabelName;

- (NSString *)transactionLabelName
{
	return [self valueForKeyPath:@"transactionLabel.name"];
}

- (void)setTransactionLabelName:(NSString *)newLabelName
{
	NSEntityDescription *labelDescription = [NSEntityDescription entityForName:@"Label" 
							    inManagedObjectContext:self.managedObjectContext];
	NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"(name like %@)", newLabelName];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:labelDescription];
	[fetchRequest setPredicate:namePredicate];
	[fetchRequest setFetchLimit:1];
	NSError *error = nil;
	NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(array == nil) {
		return;
	}
	[self setValue:[array objectAtIndex:0] forKey:@"transactionLabel"];
}

- (void)didChangeValueForKey:(NSString *)key
{
	[super didChangeValueForKey:key];
	if([key isEqual:@"account"]) {
		[self setValue:[self valueForKeyPath:@"account.balance"] forKey:@"balance"];
	}
}

- (void)awakeFromInsert {
	[self setValue:[NSDate date] forKey:@"date"];
	[self setTransactionLabelName:@"-"];
}

- (void)setValue:(id)newValue forKey:(id)key
{
	[super setValue:newValue forKey:key];
	if([key isEqual:@"deposit"] || [key isEqual:@"withdrawal"] || [key isEqual:@"date"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ZXAccountTotalDidChangeNotification object:self];
	} else if([key isEqual:@"transactionLabel"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ZXTransactionLabelDidChangeNotification object:self];
	}
}

@end
