/*
 * Name: 	ZXReportSection.m
 * Project:	Strongbox
 * Created on:	2008-07-04
 *
 * Copyright (C) 2008 Pierre-Hans Corcoran
 *
 * --------------------------------------------------------------------------
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License (version 2) as published 
 *  by the Free Software Foundation. This program is distributed in the 
 *  hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
 *  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 *  See the GNU General Public License for more details. You should have 
 *  received a copy of the GNU General Public License along with this 
 *  program; if not, write to the Free Software Foundation, Inc., 51 
 *  Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 * --------------------------------------------------------------------------
 */

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
