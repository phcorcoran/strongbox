//
//  ZXTransactionMO.m
//  Cashbox
//
//  Created by Pierre-Hans on 04/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXTransactionMO.h"


@implementation ZXTransactionMO

@dynamic transactionLabelName;

- (NSString *)transactionLabelName
{
	return [self valueForKeyPath:@"transactionLabel.name"];
}

- (void)setTransactionLabelName:(NSString *)newLabelName
{
	NSEntityDescription *labelDescription = [NSEntityDescription entityForName:@"Label" 
							    inManagedObjectContext:self.managedObjectContext];
	NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"(name like %@)", newLabelName];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:labelDescription];
	[fetchRequest setPredicate:namePredicate];
	[fetchRequest setFetchLimit:1];
	NSError *error = nil;
	NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(array == nil) {
		return;
	}
	[self setValue:[array objectAtIndex:0] forKey:@"transactionLabel"];
}


- (void)awakeFromInsert {
	[self setValue:[NSDate date] forKey:@"date"];
}

- (void)setValue:(id)newValue forKey:(id)key
{
	[super setValue:newValue forKey:key];
	if([key isEqual:@"deposit"] || [key isEqual:@"withdrawal"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ZXAccountTotalDidChangeNotification object:self];
	} else if([key isEqual:@"transactionLabel"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ZXTransactionLabelDidChangeNotification object:self];
	}
}

- (NSNumber *)balance
{
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Transaction" 
							     inManagedObjectContext:self.managedObjectContext];
	NSPredicate *balancePredicate = [NSPredicate predicateWithFormat: @"(date <= %@) AND (account.name like %@)", [self valueForKey:@"date"], [self valueForKeyPath:@"account.name"]];
	
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:entityDescription];
	[fetchRequest setPredicate:balancePredicate];
	NSError *error = nil;
	NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(array == nil) {
		return nil;
	}
	return [NSNumber numberWithDouble:[[array valueForKeyPath:@"@sum.deposit"] doubleValue] - [[array valueForKeyPath:@"@sum.withdrawal"] doubleValue]];
}
@end
