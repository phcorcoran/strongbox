/*
 * Name: 	ZXReportSection.h
 * Project:	Cashbox
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

#import <Cocoa/Cocoa.h>


@interface ZXReportSection : NSObject {
	NSString *name;
	NSColor *color;
	NSNumber *amount;
}
@property(copy) NSString *name;
@property(copy) NSColor *color;
@property(copy) NSNumber *amount;
+ (ZXReportSection *)sectionWithColor:(NSColor *)color amount:(NSNumber *)amount name:(NSString *)name;
- (ZXReportSection *)initWithColor:(NSColor *)color amount:(NSNumber *)amount name:(NSString *)name;
- (double)fractionForTotal:(double)totalAmount;
@end
