//
//  ZXColorToDataTransformer.m
//  Cashbox
//
//  Created by Pierre-Hans on 13/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXColorToDataTransformer.h"


@implementation ZXColorToDataTransformer
+ (Class)transformedValueClass
{
	return [NSData class];
}

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

- (id)transformedValue:(id)value
{
	if (value == nil) return nil;
	return [NSArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
	if (value == nil) return nil;
	return [NSUnarchiver unarchiveObjectWithData:value];
}
@end
