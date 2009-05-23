/*
 * Name: 	ZXOvalTextFieldCell.m
 * Project:	Strongbox
 * Created on:	2009-05-22
 *
 * Copyright (C) 2009 Pierre-Hans Corcoran
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

/*
 * Original File WYOvalTextFieldCell.m by Whitney Young
 * Copyright (C) 2004  Whitney Young
*/

#import "ZXOvalTextFieldCell.h"

@implementation NSActionCell(OvalCellAdditions)
- (BOOL)isOvalCell {
	return NO;
}
@end

@implementation ZXOvalTextFieldCell
@synthesize shouldDrawOval, shouldDrawBorder, shouldDrawRightOval, shouldDrawLeftOval;
@synthesize ovalColor, borderColor;

- (BOOL)isOvalCell {
	return YES;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSRect inner = cellFrame;
	BOOL oval = [shouldDrawOval boolValue];
	BOOL border = [shouldDrawBorder boolValue];
	BOOL rightOval = [shouldDrawRightOval boolValue];
	BOOL leftOval = [shouldDrawLeftOval boolValue];
	inner.size.width += 3;
	inner.origin.x -= 1;
	//inner.origin.y -= 1;
	//inner.size.height += 1;
	
	if(([[ovalColor colorSpaceName] isEqual:@"NSCalibratedWhiteColorSpace"] && [ovalColor isEqual:[NSColor whiteColor]]) ||
		([[ovalColor colorSpaceName] isEqual:@"NSDeviceRGBColorSpace"] && 
		 [ovalColor redComponent] > 0.99 && 
		 [ovalColor greenComponent] > 0.99 && 
		 [ovalColor blueComponent] > 0.99)) {
		NSRange r = [(NSTableView *)controlView rowsInRect:cellFrame];
		id colors = [NSColor controlAlternatingRowBackgroundColors];
		ovalColor = [colors objectAtIndex:r.location % 2];
	}
	
	// draw the left
	if(leftOval)
	{
		NSRect left;
		NSDivideRect(inner, &left, &inner, inner.size.height, NSMinXEdge);
		if (border && borderColor) {
			if (![self isHighlighted] && oval) {
				[borderColor set]; 
				[[NSBezierPath bezierPathWithOvalInRect:left] fill]; 
			}
			double w = 1.0;
			left.size.width -= (w * 2); 
			left.size.height -= (w * 2); 
			left.origin.x += w; 
			left.origin.y += w;
		}
		if (![self isHighlighted] && oval) { 
			[ovalColor set];
			[[NSBezierPath bezierPathWithOvalInRect:left] fill];
		}
		inner = NSMakeRect(inner.origin.x - (inner.size.height / 2), 
				   inner.origin.y, 
				   inner.size.width + (inner.size.height / 2), 
				   inner.size.height);
	}
	// draw the right
	if (rightOval)
	{
		NSRect right;
		NSDivideRect(inner, &right, &inner, inner.size.height, NSMaxXEdge);
		if (border && borderColor) {
			if (![self isHighlighted] && oval) { 
				[borderColor set];
				[[NSBezierPath bezierPathWithOvalInRect:right] fill]; 
			}
			double w = 1.0;
			right.size.width -= (w * 2); 
			right.size.height -= (w * 2); 
			right.origin.x += w; 
			right.origin.y += w;
		}
		if (![self isHighlighted] && oval) { 
			[ovalColor set]; 
			[[NSBezierPath bezierPathWithOvalInRect:right] fill];
		}
		inner = NSMakeRect(inner.origin.x, 
				   inner.origin.y, 
				   inner.size.width + (inner.size.height / 2), 
				   inner.size.height);
	}
	// draw interior
	if (border && borderColor) {
		if (![self isHighlighted] && oval) { 
			[borderColor set];
			[NSBezierPath fillRect:inner];
		}
		double w = 1.0;
		inner.size.height -= (w * 2);
		inner.size.width += (w * 2);
		inner.origin.x -= w;
		inner.origin.y += w;
	}
	if (![self isHighlighted] && oval) {
		[ovalColor set]; 
		[NSBezierPath fillRect:inner];
	}
	
	[super drawWithFrame:inner inView:controlView];
}

- (void)dealloc
{
	[shouldDrawOval release];
	[shouldDrawBorder release];
	[shouldDrawRightOval release];
	[shouldDrawLeftOval release];
	[ovalColor release];
	// This caused some crashes.
	//[borderColor release];
	[super dealloc];
}
@end