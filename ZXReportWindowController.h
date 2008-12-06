/*
 * Name: 	ZXReportWindowController.h
 * Project:	Strongbox
 * Created on:	2008-04-13
 *
 * Copyright (C) 2008 Pierre-Hans Corcoran
 *
 * --------------------------------------------------------------------------
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License (version 2) as published 
 *  by the Free Software Foundation. This program is distributed in the 
 *  hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
 *  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 *  See the GNU General Public License for more details. You should have 
 *  received a copy of the GNU General Public License along with this 
 *  program; if not, write to the Free Software Foundation, Inc., 51 
 *  Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 * --------------------------------------------------------------------------
 */

#import <Cocoa/Cocoa.h>

@class ZXReportGraphView, ZXReportTextView, ZXDocument, ZXReportHistView;
@interface ZXReportWindowController : NSObject {
	ZXDocument *owner;
	IBOutlet NSWindow *reportWindow;
	IBOutlet ZXReportGraphView *graphView;
	IBOutlet ZXReportHistView *histView;
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
- (IBAction)toggleReportWindow:(id)sender;
- (IBAction)updateView:(id)sender;
- (IBAction)toggleDetailBox:(id)sender;
@end
