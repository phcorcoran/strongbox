//
//  ZXLabelMO.m
//  Cashbox
//
//  Created by Pierre-Hans on 16/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXLabelMO.h"

// For debugging purposes
@implementation ZXLabelMO

- (id)valueForKey:(id)key
{
	NSLog(@"key = %@", key);
	if(key == nil) {
		NSLog(@"booo");
	}
	return [super valueForKey:key];
}
@end
