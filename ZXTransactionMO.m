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

- (void)didChangeValueForKey:(NSString *)key
{
	[super didChangeValueForKey:key];
	if([key isEqual:@"account"]) {
		[self setValue:[self valueForKeyPath:@"account.balance"] forKey:@"balance"];
	}
}

- (void)awakeFromInsert {
	[self setValue:[NSDate date] forKey:@"date"];
	[self setTransactionLabelName:@"-"];
}

- (void)setValue:(id)newValue forKey:(id)key
{
	[super setValue:newValue forKey:key];
	if([key isEqual:@"deposit"] || [key isEqual:@"withdrawal"] || [key isEqual:@"date"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ZXAccountTotalDidChangeNotification object:self];
	} else if([key isEqual:@"transactionLabel"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ZXTransactionLabelDidChangeNotification object:self];
	}
}

@end
