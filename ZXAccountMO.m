//
//  ZXAccountMO.m
//  Cashbox
//
//  Created by Pierre-Hans on 16/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXAccountMO.h"


@implementation ZXAccountMO
- (void)awakeFromInsert
{
	[super awakeFromInsert];
	NSString *name = [self valueForKey:@"name"];
	[super setValue:@"" forKey:@"name"];
	[self setValue:name forKey:@"name"];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if([key isEqual:@"name"]) {
		value = [self uniqueNewName:value];
	}
	[super setValue:value forKey:key];
}

- (NSString *)uniqueNewName:(NSString *)newDesiredName
{
	NSString *allowedName = newDesiredName;
	int counter = 1;
	NSDictionary *usedNames = [self usedNames];
	NSLog(@"uN = %@", usedNames);
	while([usedNames valueForKey:allowedName] != nil) {
		allowedName = [NSString stringWithFormat:@"%@ %d", newDesiredName, counter++];
	}
	return allowedName;
}

- (NSDictionary *)usedNames
{
	NSEntityDescription *desc = [NSEntityDescription entityForName:@"Account" 
						inManagedObjectContext:self.managedObjectContext];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:desc];
	
	NSError *error = nil;
	NSArray *allAccounts = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(allAccounts == nil) {
		//FIXME: What should be done here if fetch request yields nil?
		return nil;
	}
	NSMutableDictionary *usedNamesDict = [[NSMutableDictionary alloc] initWithCapacity:[allAccounts count]];
	for(id account in allAccounts) {
		[usedNamesDict setValue:[account objectID] forKey:[account valueForKey:@"name"]];
	}
	return usedNamesDict;
}

- (NSString *)total
{
	NSArray *array = [self valueForKey:@"transactions"];
	
	id total = [NSNumber numberWithDouble:[[array valueForKeyPath:@"@sum.deposit"] doubleValue] - [[array valueForKeyPath:@"@sum.withdrawal"] doubleValue]];
	return [[ZXCurrencyFormatter currencyFormatter] stringFromNumber:total];
}
@end
