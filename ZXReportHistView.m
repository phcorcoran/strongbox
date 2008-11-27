//
//  ZXReportHistView.m
//  Cashbox
//
//  Created by Pierre-Hans on 23/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

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
		NSLog(@"%f", a/maxAmount * h);
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
