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
	NSLog(@"au moins... %@", accountController);
	id arr = [accountController arrangedObjects];
	NSLog(@"arrCount = %d", [arr count]);
	id selectedAccount = nil;
	for(id account in arr) {
		NSLog(@"n = %@", [account valueForKey:@"name"]);
		if([[account valueForKey:@"name"] isEqual:[[self content] valueForKey:@"currentAccountName"]]) {
			NSLog(@"that's surprising");
			selectedAccount = account;
			break;
		}
	}
	
	if(selectedAccount == nil) {
		NSLog(@"as predicted");
		NSLog(@"--------------");
		return;
	}
	NSLog(@"--------------");
	[accountController setSelectionIndexes:[NSIndexSet indexSet]]; // Clear selection
	[accountController addSelectedObjects:[NSArray arrayWithObject:selectedAccount]];
}

- (void)updateCurrentAccountName
{
	[[self content] setValue:[accountController valueForKeyPath:@"selection.name"] forKey:@"currentAccountName"];
}
@end
