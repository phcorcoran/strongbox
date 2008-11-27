//
//  ZXReportTextView.m
//  Cashbox
//
//  Created by Pierre-Hans on 04/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXReportTextView.h"

@implementation ZXReportTextView

@synthesize lastWidthModification;

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
	[_target release];
	[super dealloc];
}

- (void)addSection:(ZXReportSection *)section
{
	[allSections addObject:section];
//	NSLog(@"Adding a section %@", allSections);
	
	// Magic rect
	NSTextField *text = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 600, 20)];
	[text setBordered:NO];
	[text setEditable:NO];
	[text setSelectable:NO];
	[text setDrawsBackground:NO];
	
	// FIXME: Hard-coded formatter
	NSString *content = [NSString stringWithFormat:@"%@: %@", section.name, [currencyFormatter stringFromNumber:section.amount]];
	
	NSAttributedString *string = [[NSAttributedString alloc] initWithString:content
								     attributes:[NSDictionary dictionaryWithObjectsAndKeys:section.color
										 , @"NSColor", nil, nil]];
	
	[text setAttributedStringValue:string];
	[string release];
	
	[text sizeToFit];
	NSRect frame = [text frame];
	
	// Position to top of frame, below last added entry.
	frame.origin.y = [self frame].size.height - frame.size.height * [allSections count];
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
		frame.size.width += difference; // Equal to frame.size.width = [text frame].size.width
		frame.origin.x -= difference;
		[self setFrame:frame];
		
		self.lastWidthModification = [NSNumber numberWithFloat:difference];
	}
	[text release];
	
}

- (void)removeAllSections
{
	[allSections removeAllObjects];
	while ([[self subviews] count] > 0)
	{
		[[[self subviews] objectAtIndex:0] removeFromSuperview];
	}
}

- (void)mouseDown:(NSEvent *)theEvent
{
	if ([theEvent clickCount] > 0) {
		[self sendAction:[self action] to:[self target]];
	}
	[super mouseDown:theEvent];
}

- (void)setTarget:(id)target
{
	if (target != _target)
	{
		[_target release];
		_target = [target retain];
	}
}
- (id)target
{
	return _target;
}
- (void)setAction:(SEL)action
{
	_action = action;
}
- (SEL)action
{
	return _action;
}

@end
