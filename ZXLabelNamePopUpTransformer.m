//
//  ZXLabelNamePopUpTransformer.m
//  Cashbox
//
//  Created by Pierre-Hans on 07/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXLabelNamePopUpTransformer.h"


@implementation ZXLabelNamePopUpTransformer
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
	NSLog(@"aaa");
	
	return [[[NSAttributedString alloc] initWithString:value 
						attributes:[NSDictionary dictionaryWithObject:[NSColor redColor]
													forKey:NSForegroundColorAttributeName]] autorelease];
}
@end
