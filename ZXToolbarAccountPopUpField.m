//
//  ZXToolbarAccountPopUpField.m
//  Cashbox
//
//  Created by Pierre-Hans on 03/06/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXToolbarAccountPopUpField.h"


@implementation ZXToolbarAccountPopUpField

- (void)awakeFromNib
{
	[self setView:customPopUp];
	[self setMinSize:NSMakeSize(100, NSHeight([customPopUp frame]))];
	[self setMaxSize:NSMakeSize(150, NSHeight([customPopUp frame]))];
}

@end
