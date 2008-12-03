/*
 * Name: 	ZXLabelController.m
 * Project:	Cashbox
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

static ZXLabelMO *sharedNoLabelObject = nil;

@implementation ZXLabelController
@synthesize usedNames, noLabel;

- (void)setupNoLabelObject
{
	NSString *noLabelString = @"-";
	noLabel = [[ZXLabelMO alloc] initWithEntity:[NSEntityDescription entityForName:@"Label" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
	[noLabel specialSetName:noLabelString];
	[noLabel setValue:[NSNumber numberWithBool:YES] forKey:@"isImmutable"];
}

- (id)init
{
	if(self = [super init]) {
		self.usedNames = [NSMutableDictionary dictionary];
	}
	return self;
}

//! Is responsible for last-minute preparation of the controller/entity
/*!
 This fonction will most likely never be called by the programmer. It is called just before the controller is up and ready. It is activated when the button "Automatically prepare content" is clicked in Interface Builder. In this case, what it should do is check whether the controller's array is empty. If it is, it adds a new instance of the entity. If it isn't, it does nothing.
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
	
	NSString *noLabelString = @"-";
	if([array count] < 1) {
		[self setupNoLabelObject];
		[self addObject:noLabel];
	} else {
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name LIKE %@)", noLabelString];
		[fetchRequest setPredicate:pred];
		array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if(array == nil) {
			return;
		}
		noLabel = [array objectAtIndex:0];
	}
	
	[self updateUsedNames];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(validatesNewLabelName:) name:ZXLabelNameDidChangeNotification object:nil];
}

- (void)setContent:(id)content
{
	[super setContent:content];
	[[NSNotificationCenter defaultCenter] postNotificationName:ZXLabelControllerDidLoadNotification 
							    object:self];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
}

- (id)newObject
{
	id obj = [super newObject];
	// FIXME: Hard-coded english
	[obj specialSetName:[self uniqueNewName:@"New Label"]];
	[self.usedNames setValue:[obj objectID] forKey:[obj valueForKey:@"name"]];
	return obj;
}

- (void)validatesNewLabelName:(NSNotification *)aNotification
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
	NSEntityDescription *desc = [NSEntityDescription entityForName:@"Label" 
						inManagedObjectContext:self.managedObjectContext];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:desc];
	
	NSError *error = nil;
	NSArray *allLabels = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(allLabels == nil) {
		return;
	}
	NSMutableDictionary *usedNamesDict = [[NSMutableDictionary alloc] initWithCapacity:[allLabels count]];
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
