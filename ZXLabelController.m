/*
 * Name: 	ZXLabelController.m
 * Project:	Strongbox
 * Created on:	2008-07-30
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

#import "ZXLabelController.h"
#import "ZXLabelMO.h"
#import "ZXNotifications.h"

static NSString *sharedNoLabelString = @"-";

@interface ZXLabelController (Private)
- (void)validatesNewLabelName:(NSNotification *)aNotification;
- (void)setupNoLabelObject;
- (NSString *)uniqueNewName:(NSString *)newDesiredName;
- (void)updateUsedNames;
@end

@implementation ZXLabelController
@synthesize usedNames, noLabel;

- (ZXLabelMO *)noLabel 
{
	if(!noLabel) {
		id array;
		NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
		[fetchRequest setEntity:[NSEntityDescription entityForName:@"Label" 
						    inManagedObjectContext:self.managedObjectContext]];
		
		NSError *error = nil;
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name LIKE %@)", sharedNoLabelString];
		[fetchRequest setPredicate:pred];
		array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if(array == nil) return nil;
		self.noLabel = [array objectAtIndex:0];
	}
	return noLabel;
}

//! Initialization of the "no-label" object
/*! This object is unique for each document */
- (void)setupNoLabelObject
{
	self.noLabel = [[[ZXLabelMO alloc] initWithEntity:[NSEntityDescription entityForName:@"Label" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext] autorelease];
	[self.noLabel specialSetName:sharedNoLabelString];
	[self.noLabel setValue:[NSNumber numberWithBool:YES] forKey:@"isImmutable"];
	
}

- (id)init
{
	if(self = [super init]) {
		self.usedNames = [NSMutableDictionary dictionary];
	}
	return self;
}

//! Prepares the content of the controller
/*!
 Sets up the noLabel object, updates the used names.
 */
- (void)prepareContent
{
	[super prepareContent];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Label" 
					    inManagedObjectContext:self.managedObjectContext]];
	
	NSError *error = nil;
	NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(array == nil) {
		return;
	}
		
	if([array count] < 1) {
		[self setupNoLabelObject];
		[self addObject:noLabel];
	}
	
	[self updateUsedNames];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(validatesNewLabelName:) name:ZXLabelNameDidChangeNotification object:nil];
}

//- (void)setContent:(id)content
//{
//	[super setContent:content];
//	[[NSNotificationCenter defaultCenter] postNotificationName:ZXLabelControllerDidLoadNotification 
//							    object:self];
//}

//! Creates a new object
/*! 
 Sets up new name to hard-coded "New Label" (to fix)
 */
- (id)newObject
{
	id obj = [super newObject];
	// FIXME: Hard-coded english
	[obj specialSetName:[self uniqueNewName:@"New Label"]];
	[self.usedNames setValue:[obj objectID] forKey:[obj valueForKey:@"name"]];
	return obj;
}

//! Sets the name of the label in the notification to avoid conflicts.
/*! 
 This function changes the name of the label in the notification if there is
 a duplicate with existing labels.
 \param aNotification NSNotification containing the new label as object.
 \sa uniqueNewName:
 */
- (void)validatesNewLabelName:(NSNotification *)aNotification
{
	id obj = [aNotification object];
	NSLog(@"%@", [self content]);
	if(![[self content] containsObject:obj]) return;
	[obj specialSetName:[self uniqueNewName:[obj valueForKey:@"name"]]];
	[self updateUsedNames];
}

//! Generates a non-conflicting name from given name
/*! 
 Returns a new name from the given so that no conflict arises inserting a new 
 label with that name. Appends a number after the name if already exists.
 \param newDesiredName String containing the desired name of the label.
 \return Same or modified name depending on if conflict was found. 
 */
- (NSString *)uniqueNewName:(NSString *)newDesiredName
{
	NSString *allowedName = newDesiredName;
	int counter = 1;
	while([self.usedNames valueForKey:allowedName]) {
		allowedName = [NSString stringWithFormat:@"%@ %d", newDesiredName, counter++];
	}
	return allowedName;
}

//! Update the dictionary of used names to reflect current state
/*! 
 Used when change is done on controlled objects. Costly operation, uses fetch in
 CoreData store to retrieve names.
 */
- (void)updateUsedNames
{
	NSEntityDescription *desc = [NSEntityDescription entityForName:@"Label" 
						inManagedObjectContext:self.managedObjectContext];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:desc];
	
	NSError *error = nil;
	NSArray *allLabels = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(allLabels == nil) {
		return;
	}
	NSMutableDictionary *usedNamesDict = [NSMutableDictionary dictionaryWithCapacity:[allLabels count]];
	for(id label in allLabels) {
		if([label valueForKey:@"name"] == nil) continue;
		[usedNamesDict setValue:[label objectID] forKey:[label valueForKey:@"name"]];
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
