/*
 * Name: 	ZXReportGraphView.m
 * Project:	Strongbox
 * Created on:	2008-06-07
 *
 * Copyright (C) 2008 Pierre-Hans Corcoran
 *
 * --------------------------------------------------------------------------
 *  This program is  free software;  you can redistribute  it and/or modify it
 *  under the terms of the GNU General Public License (version 2) as published 
 *  by  the  Free Software Foundation.  This  program  is  distributed  in the 
 *  hope  that it will be useful,  but WITHOUT ANY WARRANTY;  without even the 
 *  implied warranty of MERCHANTABILITY  or  FITNESS FOR A PARTICULAR PURPOSE.  
 *  See  the  GNU General Public License  for  more  details.  You should have 
 *  received  a  copy  of  the  GNU General Public License   along  with  this 
 *  program;   if  not,  write  to  the  Free  Software  Foundation,  Inc., 51 
 *  Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 * --------------------------------------------------------------------------
 */

#import "ZXReportGraphView.h"
#import "ZXReportSection.h"

@implementation ZXReportGraphView
- (void)drawRect:(NSRect)rect
{
	float radius = (rect.size.width < rect.size.height) ? rect.size.width / 2: rect.size.height / 2;
	NSPoint center = NSMakePoint(radius, rect.size.height - radius);
	NSBezierPath *path;
	double currentAngle = 90;
	
	id sortDesc = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"amount" ascending:YES] autorelease]];
	[allSections sortUsingDescriptors:sortDesc];
	
	if ([allSections count] < 1)
	{
//FIXME: Magic error message
		NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"No Information Available"
									     attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor redColor], @"NSColor", nil, nil]];
		[string drawAtPoint:NSMakePoint((rect.size.width - [string size].width) / 2,rect.size.height - 20)];
		[string release];
		return;
	}
	
	double totalAmount = [[self valueForKeyPath:@"allSections.@sum.amount"] doubleValue];
	
	for(ZXReportSection *section in allSections)
	{
		double endAngle = currentAngle - 360 * [section fractionForTotal:totalAmount];
		[section.color set];
		path = [NSBezierPath bezierPath];
		[path moveToPoint:center];
		[path appendBezierPathWithArcWithCenter:center radius:radius startAngle:currentAngle endAngle:endAngle clockwise:YES];	
		[path closePath];
		[path fill];
		[[NSColor whiteColor] set];
		[path setLineWidth:0.5];
		[path stroke];
		currentAngle = endAngle;
		
	}
}
@end
