//
//  ZXDocumentController.m
//  Cashbox
//
//  Created by Pierre-Hans on 15/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXDocumentController.h"


@implementation ZXDocumentController

- (void)prepareContent
{
	[self setContent:[self newObject]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentAccountName) name:ZXActiveAccountDidChangeNotification object:nil];
}

- (void)updateCurrentAccountName
{
	[[self content] setValue:[accountController valueForKeyPath:@"selection.name"] forKey:@"currentAccountName"];
}
@end
