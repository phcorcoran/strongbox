//
//  ZXAccountMO.m
//  Cashbox
//
//  Created by Pierre-Hans on 16/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXAccountMO.h"


@implementation ZXAccountMO

- (void)setValue:(id)value forKey:(NSString *)key
{
	[super setValue:value forKey:key];
	if([key isEqual:@"name"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ZXAccountNameDidChangeNotification object:self];
	}
}

- (void)specialSetName:(NSString *)newName
{
	[super setValue:newName forKey:@"name"];
}

- (void)recalculateBalance:(NSNotification *)note
{
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:self.managedObjectContext];
	
	NSPredicate *balancePredicate = [NSPredicate predicateWithFormat: @"account == %@", self];
	id dateSort = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES] autorelease]];
	
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:entityDescription];
	[fetchRequest setPredicate:balancePredicate];
	[fetchRequest setSortDescriptors:dateSort];
	NSError *error = nil;
	NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(array == nil) {
		return;
	}
	
	double balance = 0;
	for(id obj in array) {
		double add = [[obj valueForKey:@"deposit"] doubleValue] - [[obj valueForKey:@"withdrawal"] doubleValue];
		balance += add;
		[obj setValue:[NSNumber numberWithDouble:balance] forKey:@"balance"];
	}
	[self setValue:[NSNumber numberWithDouble:balance] forKey:@"balance"];
}

@end
