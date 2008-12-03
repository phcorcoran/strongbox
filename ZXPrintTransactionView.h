//
//  ZXPrintTransactionView.h
//  Cashbox
//
//  Created by Pierre-Hans on 30/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ZXDocument;
@interface ZXPrintTransactionView : NSView {
	ZXDocument *owner;
	NSMutableDictionary *attributes;
	NSMutableParagraphStyle *centeredStyle;
	NSMutableParagraphStyle *rightStyle;
	NSSize paperSize;
	float topMargin;
	float leftMargin;
	NSRect titleRect;
	NSRect subtitleRect;
}
- (id)initWithOwner:(ZXDocument *)owner;
- (NSRect)rectForTransaction:(int)i;
- (int)transactionsPerPage;
@end
