//
//  ZXAccountController.m
//  Cashbox
//
//  Created by Pierre-Hans on 03/06/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXAccountController.h"

@implementation ZXAccountController
@synthesize usedNames;

- (id)init
{
	if(self = [super init]) {
		self.usedNames = [NSMutableDictionary dictionary];
	}
	return self;
}

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
	[self updateUsedNames];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(validatesNewAccountName:) name:ZXAccountNameDidChangeNotification object:nil];
}

- (void)setValue:(id)newValue forKey:(id)key
{
	[super setValue:newValue forKey:key];
	if([key isEqual:@"selectionIndex"] || [key isEqual:@"selectionIndexes"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ZXActiveAccountDidChangeNotification object:self];
	}
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recalculateBalance:) name:ZXAccountTotalDidChangeNotification object:nil];
}

- (void)recalculateBalance:(NSNotification *)note
{
	[[self valueForKeyPath:@"selection.self"] recalculateBalance:note];
}

- (id)newObject
{
	id obj = [super newObject];
	// FIXME: Hard-coded english
	[obj specialSetName:[self uniqueNewName:@"New Account"]];
	[self.usedNames setValue:[obj objectID] forKey:[obj valueForKey:@"name"]];
	return obj;
}

- (void)validatesNewAccountName:(NSNotification *)aNotification
{
	id obj = [aNotification object];
	[obj specialSetName:[self uniqueNewName:[obj valueForKey:@"name"]]];
	[self updateUsedNames];
}

- (NSString *)uniqueNewName:(NSString *)newDesiredName
{
	NSString *allowedName = newDesiredName;
	int counter = 1;
	while([self.usedNames valueForKey:allowedName]) {
		allowedName = [NSString stringWithFormat:@"%@ %d", newDesiredName, counter++];
	}
	return allowedName;
}

- (void)updateUsedNames
{
	NSEntityDescription *desc = [NSEntityDescription entityForName:@"Account" 
						inManagedObjectContext:self.managedObjectContext];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:desc];
	
	NSError *error = nil;
	NSArray *allAccounts = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(allAccounts == nil) {
		return;
	}
	NSMutableDictionary *usedNamesDict = [NSMutableDictionary dictionaryWithCapacity:[allAccounts count]];
	for(id account in allAccounts) {
		if([account valueForKey:@"name"] == nil) continue;
		[usedNamesDict setValue:[account objectID] forKey:[account valueForKey:@"name"]];
	}
	self.usedNames = usedNamesDict;
}

- (IBAction)remove:(id)sender
{
	[super remove:sender];
	[self updateUsedNames];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}
@end
