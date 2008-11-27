//
//  ZXAccountController.m
//  Cashbox
//
//  Created by Pierre-Hans on 03/06/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXAccountController.h"

//! Dull subclass of NSArrayController to override methods
/*!
 This class probably should not be instantiated by the programmer. It is intended to work with Interface Builder, for the prepareContent method.
 */
@implementation ZXAccountController

//! Is responsible for last-minute preparation of the controller/entity
/*!
 This fonction will most likely never be called by the programmer. It is called just before the controller is up and ready. It is activated when the button "Automatically prepare content" is clicked in Interface Builder. In this case, what it should do is check whether the controller's array is empty. If it is, it adds a new instance of the entity. If it isn't, it does nothing.
 */
- (void)prepareContent
{
	[super prepareContent];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Account" 
					    inManagedObjectContext:self.managedObjectContext]];
	
	NSError *error = nil;
	NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(array == nil) {
		return;
	}
	if([array count] < 1) {
		[self add:self];
	}
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOverview:) name:ZXAccountTotalDidChangeNotification object:nil];
}

- (IBAction)updateOverview:(id)sender
{
	[self willChangeValueForKey:@"selection"];
	//	selection = [self valueForKey:@"selection"];
	[self didChangeValueForKey:@"selection"];
	[transactionOverviewTextField display];
}
@end
