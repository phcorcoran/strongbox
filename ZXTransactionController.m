//
//  ZXTransactionController.m
//  Cashbox
//
//  Created by Pierre-Hans on 09/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

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
