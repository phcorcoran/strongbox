/*
 * Name: 	ZXTransactionController.m
 * Project:	Cashbox
 * Created on:	2008-07-09
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

#import "ZXTransactionController.h"


@implementation ZXTransactionController


- (IBAction)add:(id)sender
{
	[super add:sender];
	[[NSNotificationCenter defaultCenter] postNotificationName:ZXAccountTotalDidChangeNotification object:self];
}

- (IBAction)remove:(id)sender
{
	[super remove:sender];
	[[NSNotificationCenter defaultCenter] postNotificationName:ZXAccountTotalDidChangeNotification object:self];
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
		if ([[candidate commonPrefixWithString:prefix options:NSCaseInsensitiveSearch] length] == [prefix length]) {
			completion = candidate;
			break;
		}
	}
	return completion;
}

@end
