//
//  ZXReportTextView.h
//  Cashbox
//
//  Created by Pierre-Hans on 04/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZXReportSection.h"


@interface ZXReportTextView : NSControl {
	id _target;
	SEL _action;
	NSMutableArray *allSections;
	IBOutlet NSNumberFormatter *currencyFormatter;
	NSNumber *lastWidthModification;
}

@property(retain) NSNumber *lastWidthModification;

- (void)addSection:(ZXReportSection *)section;
- (void)removeAllSections;

- (void)mouseDown:(NSEvent *)theEvent;

// overriden because there's no cell to handle these
- (void)setTarget:(id)target;
- (id)target;
- (void)setAction:(SEL)action;
- (SEL)action;
@end
