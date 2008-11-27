//
//  ZXReportSection.h
//  Cashbox
//
//  Created by Pierre-Hans on 04/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ZXReportSection : NSObject {
	NSString *name;
	NSColor *color;
	NSNumber *amount;
}
@property(copy) NSString *name;
@property(copy) NSColor *color;
@property(copy) NSNumber *amount;
+ (ZXReportSection *)sectionWithColor:(NSColor *)color amount:(NSNumber *)amount name:(NSString *)name;
- (ZXReportSection *)initWithColor:(NSColor *)color amount:(NSNumber *)amount name:(NSString *)name;
- (double)fractionForTotal:(double)totalAmount;
@end
