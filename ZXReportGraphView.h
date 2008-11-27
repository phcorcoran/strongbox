//
//  ZXReportView.h
//  Cashbox
//
//  Created by Pierre-Hans on 07/06/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZXReportSection.h"

// FIXME: Do something when there is no section
@interface ZXReportGraphView : NSView {
	NSMutableArray *allSections;
}
- (void)addSection:(ZXReportSection *)section;
- (void)removeAllSections;
@end