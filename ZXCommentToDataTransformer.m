//
//  ZXCommentToDataTransformer.m
//  Cashbox
//
//  Created by Pierre-Hans on 07/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXCommentToDataTransformer.h"


@implementation ZXCommentToDataTransformer
+ (Class)transformedValueClass
{
	return [NSAttributedString class];
}

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

- (id)transformedValue:(id)value
{
	
	NSLog(@"1: %@", [value class]);
	if (value == nil) return nil;
	return [[[NSAttributedString alloc] initWithRTFD:value documentAttributes:nil] autorelease];
}

- (id)reverseTransformedValue:(id)value
{
	NSLog(@"2: %@", [value class]);
	if (value == nil) return nil;
	return [value RTFDFromRange:NSMakeRange(0, [value length]) documentAttributes:nil];
	
}
@end
