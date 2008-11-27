//
//  ZXCurrencyValueTransformer.m
//  Cashbox
//
//  Created by Pierre-Hans on 12/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXCurrencyValueTransformer.h"

@implementation ZXCurrencyValueTransformer
- (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
	return [[ZXCurrencyFormatter currencyFormatter] stringFromNumber:value];
}
@end
