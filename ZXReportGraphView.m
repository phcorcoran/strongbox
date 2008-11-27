//
//  ZXReportView.m
//  Cashbox
//
//  Created by Pierre-Hans on 07/06/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXReportGraphView.h"

@implementation ZXReportGraphView

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
	float radius = (rect.size.width < rect.size.height) ? rect.size.width / 2: rect.size.height / 2;
	NSPoint center = NSMakePoint(radius, rect.size.height - radius);
	NSBezierPath *path;
	double currentAngle = 90;
	
	
	
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
//		NSLog(@"%f %f", currentAngle, endAngle);
		[path appendBezierPathWithArcWithCenter:center radius:radius startAngle:currentAngle endAngle:endAngle clockwise:YES];	
		[path closePath];
		[path fill];
		[[NSColor whiteColor] set];
		[path setLineWidth:0.5];
		[path stroke];
		currentAngle = endAngle;
		
	}
}

- (void)removeAllSections
{
	[allSections removeAllObjects];
}


@end
