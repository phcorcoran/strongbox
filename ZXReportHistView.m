/*
 * Name: 	ZXReportHistView.m
 * Project:	Strongbox
 * Created on:	2008-11-23
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

#import "ZXReportHistView.h"


@implementation ZXReportHistView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		allSections = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[allSections release];
	[super dealloc];
}

- (void)addSection:(ZXReportSection *)section
{
	[allSections addObject:section];
}

- (void)drawRect:(NSRect)rect
{	
	if ([allSections count] < 1)
	{
		//FIXME: Magic error message
		NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"No Information Available"
									     attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor redColor], @"NSColor", nil, nil]];
		[string drawAtPoint:NSMakePoint((rect.size.width - [string size].width) / 2,rect.size.height - 20)];
		[string release];
		return;
	}
	
	double maxAmount = [[allSections valueForKeyPath:@"@max.amount"] doubleValue];
	int h = rect.size.height - 5;
	
	id arr = [NSMutableArray array];
	for(id s in allSections) {
		double a = fabs([[s amount] doubleValue]);
		if(a/maxAmount * h < 5) continue;
		[arr addObject:s];
	}
	if([arr count] == 0) return;
	
	NSPoint curPos = NSMakePoint(10, 0);
	NSBezierPath *path;
	int w = (rect.size.width - 10) / [arr count];
	
	for(ZXReportSection *section in arr)
	{
		double curHeigth = h * [section fractionForTotal:maxAmount];
		[section.color set];
		path = [NSBezierPath bezierPath];
		[path moveToPoint:curPos];
		[path appendBezierPathWithRect:NSMakeRect(curPos.x, curPos.y, w, curHeigth)];
		[path closePath];
		[path fill];
		[[NSColor whiteColor] set];
		[path setLineWidth:0.5];
		[path stroke];
		curPos = NSMakePoint(curPos.x + w, curPos.y);
		
	}
}

- (void)removeAllSections
{
	[allSections removeAllObjects];
}

@end
