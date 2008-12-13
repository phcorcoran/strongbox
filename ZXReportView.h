//
//  ZXReportView.h
//  Strongbox
//
//  Created by Pierre-Hans on 10/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ZXReportSection;

@interface ZXReportView : NSControl {
	NSMutableArray *allSections;
}
- (void)addSection:(ZXReportSection *)section;
- (void)removeAllSections;
@end
