//
//  ZXTransactionsOverviewTransformer.m
//  Cashbox
//
//  Created by Pierre-Hans on 07/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXTransactionOverviewTransformer.h"


@implementation ZXTransactionOverviewTransformer
+ (Class)transformedValueClass 
{
	return [NSAttributedString class];
}

+ (BOOL)allowsReverseTransformation 
{ 
	return NO; 
}

- (id)transformedValue:(id)value 
{
	// FIXME: Hard-coded english
	NSArray *array = [value valueForKey:@"transactions"];
	if(array == NSNoSelectionMarker) {
		return nil;
	}
	id total = [NSNumber numberWithDouble:[[array valueForKeyPath:@"@sum.deposit"] doubleValue] - [[array valueForKeyPath:@"@sum.withdrawal"] doubleValue]];
	
	NSMutableAttributedString *result = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d transactions in %@. Total: ", [array count], [value valueForKey:@"name"]]] autorelease];
	[result appendAttributedString:[[ZXCurrencyFormatter currencyFormatter] attributedStringForObjectValue:total withDefaultAttributes:nil]];
	
	return result;
}
@end
