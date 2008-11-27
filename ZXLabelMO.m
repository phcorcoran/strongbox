//
//  ZXLabelMO.m
//  Cashbox
//
//  Created by Pierre-Hans on 30/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXLabelMO.h"


@implementation ZXLabelMO
- (void)setValue:(id)value forKey:(NSString *)key
{
	[super setValue:value forKey:key];
	if([key isEqual:@"name"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ZXLabelNameDidChangeNotification object:self];
	}
}

- (void)specialSetName:(NSString *)newName
{
	NSLog(@"Bang.");
	[super setValue:newName forKey:@"name"];
}
@end
