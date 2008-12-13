//
//  ZXReportView.m
//  Strongbox
//
//  Created by Pierre-Hans on 10/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXReportView.h"
#import "ZXReportSection.h"


@implementation ZXReportView
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

- (void)removeAllSections
{
	[allSections removeAllObjects];
}
@end
