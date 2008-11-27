//
//  ZXReportHistView.h
//  Cashbox
//
//  Created by Pierre-Hans on 23/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZXReportSection.h"

// FIXME: Do something when there is no section
@interface ZXReportHistView : NSView {
	NSMutableArray *allSections;
}
- (void)addSection:(ZXReportSection *)section;
- (void)removeAllSections;
@end
