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
@end
