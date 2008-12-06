/*
 * Name: 	ZXAccountController.m
 * Project:	Strongbox
 * Created on:	2008-06-03
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
