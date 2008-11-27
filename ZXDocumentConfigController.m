//
//  ZXDocumentController.m
//  Cashbox
//
//  Created by Pierre-Hans on 15/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXDocumentConfigController.h"


@implementation ZXDocumentConfigController
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

- (IBAction)setAccountSelection:(id)sender
{
	id arr = [accountController arrangedObjects];
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
}

- (void)updateCurrentAccountName
{
	[[self content] setValue:[accountController valueForKeyPath:@"selection.name"] forKey:@"currentAccountName"];
}
@end
