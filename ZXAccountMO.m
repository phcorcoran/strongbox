//
//  ZXAccountMO.m
//  Cashbox
//
//  Created by Pierre-Hans on 16/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXAccountMO.h"


@implementation ZXAccountMO
- (NSString *)total
{
	NSArray *array = [self valueForKey:@"transactions"];
	
	id total = [NSNumber numberWithDouble:[[array valueForKeyPath:@"@sum.deposit"] doubleValue] - [[array valueForKeyPath:@"@sum.withdrawal"] doubleValue]];
	return [[ZXCurrencyFormatter currencyFormatter] stringFromNumber:total];
}
@end
