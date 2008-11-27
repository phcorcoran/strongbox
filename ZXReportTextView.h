//
//  ZXReportTextView.h
//  Cashbox
//
//  Created by Pierre-Hans on 04/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZXReportSection.h"

enum {
	ZXMoneyReportResult = 0,
	ZXPercentReportResult = 1,
};

@interface ZXReportTextView : NSControl {
	NSMutableArray *allSections;
	IBOutlet NSNumberFormatter *currencyFormatter;
	IBOutlet NSNumberFormatter *percentFormatter;
	IBOutlet NSSegmentedControl *reportResultControl;
	NSNumber *lastWidthModification;
}

@property(retain) NSNumber *lastWidthModification;
@property(assign) NSSegmentedControl *reportResultControl;

- (void)addSection:(ZXReportSection *)section;
- (void)removeAllSections;
- (IBAction)updateView:(id)sender;
@end
