//
//  ZXReportSection.m
//  Cashbox
//
//  Created by Pierre-Hans on 04/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXReportSection.h"


@implementation ZXReportSection

@synthesize color, amount, name;

+ (ZXReportSection *)sectionWithColor:(NSColor *)newColor amount:(NSNumber *)newAmount name:(NSString *)newName
{
	return [[[ZXReportSection alloc] initWithColor:newColor amount:newAmount name:newName] autorelease];
}

- (ZXReportSection *)initWithColor:(NSColor *)newColor amount:(NSNumber *)newAmount name:(NSString *)newName
{
	if(self = [super init]) {
		self.color = newColor;
		self.amount = newAmount;
		self.name = newName;
	}
	return self;
}

- (double)fractionForTotal:(double)totalAmount
{
	if(!((-0.0001 < totalAmount) && (totalAmount < 0.0001))) {
		return self.amount.doubleValue / totalAmount;
	}
	return 0.0;
}
@end
