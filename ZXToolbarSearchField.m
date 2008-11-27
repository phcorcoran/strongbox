//
//  ZXToolbarSearchField.m
//  Cashbox
//
//  Created by Pierre-Hans on 11/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXToolbarSearchField.h"


@implementation ZXToolbarSearchField

- (void)awakeFromNib
{
	[self setView:customSearchField];
	[self setMinSize:NSMakeSize(100, NSHeight([customSearchField frame]))];
	[self setMaxSize:NSMakeSize(150, NSHeight([customSearchField frame]))];
}

@end
