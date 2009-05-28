/*
 * Name: 	ZXReportTextView.m
 * Project:	Strongbox
 * Created on:	2008-07-04
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

#import "ZXReportTextView.h"
#import "ZXReportSection.h"

enum {
	ZXMoneyReportResult = 0,
	ZXPercentReportResult = 1,
};

@interface ZXReportTextView (Private)
- (void)clearAllSubviews;
- (NSAttributedString *)attributedStringForSection:(ZXReportSection *)section;
@end


@implementation ZXReportTextView

@synthesize lastWidthModification, reportResultControl;

- (id)initWithFrame:(NSRect)frameRect
{
	
	if ((self = [super initWithFrame:frameRect]) != nil) {
		self.lastWidthModification = [NSNumber numberWithInt:0];
	}
	return self;
}

- (void)drawRect:(NSRect)frame
{
	[self updateView:self];
	[super drawRect:frame];
}

- (IBAction)updateView:(id)sender
{
	[self clearAllSubviews];
	int count = 1;
	for(ZXReportSection *section in allSections) {
		// FIXME: Magic rect
		NSRect r = NSMakeRect(0, 0, 600, 20);
		NSTextField *text = [[NSTextField alloc] initWithFrame:r];
		[text setBordered:NO];
		[text setEditable:NO];
		[text setSelectable:NO];
		[text setDrawsBackground:NO];
		
		[text setAttributedStringValue:[self attributedStringForSection:section]];
		
		[text sizeToFit];
		NSRect frame = [text frame];
		
		// Position to top of frame, below last added entry.
		frame.origin.y = [self frame].size.height - frame.size.height * count++;
		// Right align
		frame.origin.x = [self frame].size.width - [text frame].size.width;
		[text setFrame:frame];
		[self addSubview:text];
		[text setAutoresizingMask:NSViewMinYMargin | NSViewMinXMargin];
		
		// If allowed space is smaller than required.
		if ([self frame].size.width < [text frame].size.width) {
			float difference = [text frame].size.width - [self frame].size.width;
			frame = [self frame];
			frame.size.width += difference;
			frame.origin.x -= difference;
			[self setFrame:frame];
			
			self.lastWidthModification = [NSNumber numberWithFloat:difference];
		}
		[text release];
	}
}

- (void)clearAllSubviews
{
	while ([[self subviews] count] > 0) {
		[[[self subviews] objectAtIndex:0] removeFromSuperview];
	}
}

- (void)removeAllSections
{
	[super removeAllSections];
	[self clearAllSubviews];
}

- (NSAttributedString *)attributedStringForSection:(ZXReportSection *)section
{
	id amount;
	if([self.reportResultControl selectedSegment] == ZXMoneyReportResult) {
		amount = [currencyFormatter stringFromNumber:section.amount];
	} else {
		double totalAmount = [[self valueForKeyPath:@"allSections.@sum.amount"] doubleValue];
		amount = [NSNumber numberWithDouble:[section fractionForTotal:totalAmount] * 100.0];
		amount = [percentFormatter stringFromNumber:amount];
	}
	// FIXME: Hard-coded string
	NSString *content = [NSString stringWithFormat:@"%@: %@", section.name, amount];
	
	id attr = [NSDictionary dictionaryWithObjectsAndKeys:section.color, @"NSColor", nil];
	id string = [[NSAttributedString alloc] initWithString:content 
						    attributes:attr];
	return [string autorelease];
}

@end
