/*
 * Name: 	ZXLabelController.m
 * Project:	Strongbox
 * Created on:	2008-07-30
 *
 * Copyright (C) 2008 Pierre-Hans Corcoran
 *
 * --------------------------------------------------------------------------
 *  This program is  free software;  you can redistribute  it and/or modify it
 *  under the terms of the GNU General Public License (version 2) as published 
 *  by  the  Free Software Foundation.  This  program  is  distributed  in the 
 *  hope  that it will be useful,  but WITHOUT ANY WARRANTY;  without even the 
 *  implied warranty of MERCHANTABILITY  or  FITNESS FOR A PARTICULAR PURPOSE.  
 *  See  the  GNU General Public License  for  more  details.  You should have 
 *  received  a  copy  of  the  GNU General Public License   along  with  this 
 *  program;   if  not,  write  to  the  Free  Software  Foundation,  Inc., 51 
 *  Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 * --------------------------------------------------------------------------
 */

#import "ZXLabelController.h"
#import "ZXLabelMO.h"
#import "ZXNotifications.h"
#import "ZXOvalPopUpButtonCell.h"

static NSString *sharedNoLabelString = @"-";

@interface ZXLabelController (Private)
- (void)validatesNewLabelName:(NSNotification *)aNotification;
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
						    inManagedObjectContext:[self managedObjectContext]]];
		
		NSError *error = nil;
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name LIKE %@)", sharedNoLabelString];
		[fetchRequest setPredicate:pred];
		array = [[self managedObjectContext] executeFetchRequest:fetchRequest 
								   error:&error];
		if(array == nil) return nil;
		self.noLabel = [array objectAtIndex:0];
	}
	return noLabel;
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
	[[owner managedObjectContext] processPendingChanges];
	[[owner undoManager] disableUndoRegistration];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Label" 
					    inManagedObjectContext:[self managedObjectContext]]];
	
	NSError *error = nil;
	NSArray *array = [[self managedObjectContext] executeFetchRequest:fetchRequest 
								    error:&error];
	if(array == nil) {
		// FIXME: Real error management needed.
		[[owner undoManager] enableUndoRegistration];
		NSLog(@"Could not load labels: %@", error);
		return;
	}
		
	if([array count] < 1) {
		self.noLabel = [[self newObject] autorelease];
		[noLabel specialSetName:sharedNoLabelString];
		[noLabel setValue:[NSNumber numberWithBool:YES] forKey:@"isImmutable"];
	}
	
	[self updateUsedNames];
	id nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self 
	       selector:@selector(validatesNewLabelName:) 
		   name:ZXLabelDidChangeNotification 
		 object:nil];
	[[owner managedObjectContext] processPendingChanges];
	[[owner undoManager] enableUndoRegistration];
}

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
	if(!obj || ![[self content] containsObject:obj]) return;
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
	id desc = [NSEntityDescription entityForName:@"Label" 
			      inManagedObjectContext:[self managedObjectContext]];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:desc];
	
	NSError *error = nil;
	NSArray *allLabels = [[self managedObjectContext] executeFetchRequest:fetchRequest 
									error:&error];
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
	for(id obj in [self selectedObjects]) {
		if([[obj valueForKey:@"name"] isEqual:sharedNoLabelString]) return;
	}
	[super remove:sender];
	[self updateUsedNames];
}

- (NSArray *)coloredNames
{
	id labels = [self arrangedObjects];
	id ret = [NSMutableArray arrayWithCapacity:[labels count]];
	for(id label in labels) {
		if([[label valueForKey:@"obsolete"] boolValue]) continue;
		[ret addObject:[label coloredName]];
	}
	return ret;
}

- (ZXOvalPopUpButtonCell *)popUpCellWithTransaction:(id)tx
{
	id cell = [[ZXOvalPopUpButtonCell alloc] initTextCell:@"" pullsDown:NO];
	if([[self arrangedObjects] count] < 1) return nil;
	
	[cell setBordered:NO];
	for(ZXLabelMO *label in [self arrangedObjects]) {
		id item = [[cell menu] addItemWithTitle:[label valueForKey:@"name"] 
						 action:NULL 
					  keyEquivalent:@""];
		[item setAttributedTitle:[label coloredName]];
		if([[label valueForKey:@"obsolete"] boolValue]) {
			[item setHidden:YES];
		}
		[item setAction:@selector(setTransactionLabelFromPopUp:)];
		[item setTarget:tx];
	}
	return [cell autorelease];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[noLabel release];
	[usedNames release];
	[super dealloc];
}
@end
