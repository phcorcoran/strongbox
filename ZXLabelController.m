//
//  ZXLabelController.m
//  Cashbox
//
//  Created by Pierre-Hans on 30/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXLabelController.h"
#import "ZXLabelMO.h"


@implementation ZXLabelController
@synthesize usedNames;

+ (id)noLabelObject
{
	return sharedNoLabelObject;
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
	NSString *noLabelString = @"No Label";
	if([array count] < 1) {
		id noLabel = [self newObject];
		[noLabel setValue:noLabelString forKey:@"name"];
		sharedNoLabelObject = noLabel;
		[self addObject:noLabel];
	} else {
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name LIKE %@)", noLabelString];
		[fetchRequest setPredicate:pred];
		array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if(array == nil) {
			return;
		}
		sharedNoLabelObject = [array objectAtIndex:0];
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
		//FIXME: What should be done here if fetch request yields nil?
		return;
	}
	NSMutableDictionary *usedNamesDict = [[NSMutableDictionary alloc] initWithCapacity:[allLabels count]];
	for(id label in allLabels) {
		if([label valueForKey:@"name"] == nil) {
			continue;
		}
		[usedNamesDict setValue:[label objectID] forKey:[label valueForKey:@"name"]];
	}
	self.usedNames = usedNamesDict;
}

- (IBAction)remove:(id)sender
{
	[super remove:sender];
	[self updateUsedNames];
}

@end
