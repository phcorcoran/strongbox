/*
 Copyright (C) 2004  Whitney Young
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

//
//  ZXReportWindowController.h
//  Cashbox
//
//  Created by Pierre-Hans on 13/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZXDocument.h"
#import "ZXReportGraphView.h"
#import "ZXReportTextView.h"
#import "ZXNotifications.h"

enum {
	ZXAllAccountsDepositsReportType = 0,
	ZXAllAccountsWithdrawalsReportType = 1,
	ZXActiveAccountDepositsReportType = 2,
	ZXActiveAccountWithdrawalsReportType = 3,
};

enum {
	ZXAllReportTime = 0,
	ZXThisMonthReportTime = 1,
	ZXLastMonthReportTime = 2,
	ZXThisYearReportTime = 3,
	ZXLastYearReportTime = 4,
	ZXCustomReportTime = 5,
};

@class ZXReportGraphView, ZXReportTextView, ZXDocument;
@interface ZXReportWindowController : NSObject {
	ZXDocument *owner;
	IBOutlet NSWindow *reportWindow;
	IBOutlet ZXReportGraphView *graphView;
	IBOutlet ZXReportTextView *textView;
	IBOutlet NSPopUpButton *reportTypePopUpButton;
	IBOutlet NSPopUpButton *reportTimePopUpButton;
	IBOutlet NSSegmentedControl *reportResultControl;
	
	IBOutlet NSDate *reportStartDate;
	IBOutlet NSDate *reportEndDate;
	
	IBOutlet NSNumber *detailBoxHidden;
	IBOutlet NSBox *detailBox;
}

@property (assign) ZXDocument *owner;
@property (copy) NSDate *reportStartDate, *reportEndDate;
@property (assign) NSNumber *detailBoxHidden;


- (id)initWithOwner:(id)owner;
- (void)showWindow;
- (IBAction)updateView:(id)sender;
- (void)setupNotificationObserving;
- (void)resetViewsPositions;
- (IBAction)toggleDetailBox:(id)sender;
@end
