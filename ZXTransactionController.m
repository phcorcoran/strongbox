/*
 * Name: 	ZXTransactionController.m
 * Project:	Strongbox
 * Created on:	2008-07-09
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

#import "ZXTransactionController.h"
#import "ZXNotification.h"

@implementation ZXTransactionController

- (IBAction)add:(id)sender {
	[super add:sender];
	[ZXNotification enqueueNotificationName:ZXAccountTotalDidChangeNotification 
					 object:nil 
				   postingStyle:NSPostWhenIdle];
}
- (IBAction)remove:(id)sender {
	[super remove:sender];
	[ZXNotification enqueueNotificationName:ZXAccountTotalDidChangeNotification 
					 object:nil 
				   postingStyle:NSPostWhenIdle];
}

-(BOOL)isACompletion:(NSString *)aString
{
	for(NSString *candidate in [self valueForKeyPath:@"arrangedObjects.transactionDescription"]) {
		if ([candidate caseInsensitiveCompare:aString] == NSOrderedSame)
			return YES;
	}
	return NO;
}

-(NSString *)completionForPrefix:(NSString *)prefix
{
	NSString *completion = nil;
	
	// special case
	if (!prefix || [prefix length] == 0)
		return nil;
	
	for(NSString *candidate in [self valueForKeyPath:@"arrangedObjects.transactionDescription"]) {
		int length = [[candidate commonPrefixWithString:prefix 
							options:NSCaseInsensitiveSearch] length];
		if (length == [prefix length]) {
			completion = candidate;
			break;
		}
	}
	return completion;
}

//! Controls special cases of key-value changes
/*!
 Posts a ZXTransactionSelectionDidChangeNotification upon selection change.
 */
- (void)setValue:(id)newValue forKey:(id)key
{
	[super setValue:newValue forKey:key];
	if([key isEqual:@"selectionIndex"] || [key isEqual:@"selectionIndexes"]) {
		[ZXNotification postNotificationName:ZXTransactionSelectionDidChangeNotification 
					      object:self];
	}
}

@end
