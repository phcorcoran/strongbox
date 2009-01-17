//
//  ZXAccountToNameTransformer.m
//  Strongbox
//
//  Created by Pierre-Hans on 16/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ZXAccountToNameTransformer.h"


@implementation ZXAccountToNameTransformer
- (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
	return [value valueForKey:@"name"];
}
@end
