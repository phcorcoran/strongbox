//
//  ZXReportTextView.m
//  Cashbox
//
//  Created by Pierre-Hans on 04/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXReportTextView.h"

@interface ZXReportTextView (Private)
- (void)clearAllSubviews;
- (NSAttributedString *)attributedStringForSection:(ZXReportSection *)section;
@end


@implementation ZXReportTextView

@synthesize lastWidthModification, reportResultControl;

- (id)initWithFrame:(NSRect)frameRect
{
	
	if ((self = [super initWithFrame:frameRect]) != nil) {
		allSections = [[NSMutableArray alloc] init];
		self.lastWidthModification = [NSNumber numberWithInt:0];
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
		// Magic rect
		NSTextField *text = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 600, 20)];
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
		if ([self frame].size.width < [text frame].size.width)
		{
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
	while ([[self subviews] count] > 0)
	{
		[[[self subviews] objectAtIndex:0] removeFromSuperview];
	}
}

- (void)removeAllSections
{
	[allSections removeAllObjects];
	[self clearAllSubviews];
}

- (NSAttributedString *)attributedStringForSection:(ZXReportSection *)section
{
	id amount;
	if([self.reportResultControl selectedSegment] == ZXMoneyReportResult) {
		amount = [currencyFormatter stringFromNumber:section.amount];
	} else {
		double totalAmount = [[self valueForKeyPath:@"allSections.@sum.amount"] doubleValue];
		amount = [percentFormatter stringFromNumber:[NSNumber numberWithDouble:[section fractionForTotal:totalAmount] * 100.0]];
	}
	// FIXME: Hard-coded string
	NSString *content = [NSString stringWithFormat:@"%@: %@", section.name, amount];
	
	NSAttributedString *string = [[NSAttributedString alloc] initWithString:content
								     attributes:[NSDictionary dictionaryWithObjectsAndKeys:section.color
										 , @"NSColor", nil, nil]];
	return [string autorelease];
}

@end
