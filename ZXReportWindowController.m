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
//  ZXReportWindowController.m
//  Cashbox
//
//  Created by Pierre-Hans on 13/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXReportWindowController.h"

@implementation ZXReportWindowController

@synthesize owner, reportStartDate, reportEndDate, detailBoxHidden;

- (id)initWithOwner:(id)newOwner;
{
	self = [super init];
	self.owner = newOwner;
	self.reportStartDate = [NSDate distantPast];
	self.reportEndDate = [NSDate date];
	self.detailBoxHidden = [NSNumber numberWithBool:YES];
	return self;
}

- (IBAction)toggleReportWindow:(id)sender
{
	BOOL mustUpdate = NO;
	if(!reportWindow) {
		[NSBundle loadNibNamed:@"ReportWindow" owner:self];
		mustUpdate = YES;
	}
	if([reportWindow isVisible] == NO || mustUpdate) {
		[self setupNotificationObserving];
		[self updateView:self];
		[reportWindow makeKeyAndOrderFront:nil];
	} else {
		[reportWindow performClose:self];
	}
}

- (void)setupNotificationObserving
{
	id defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter addObserver:self 
			  selector:@selector(updateView:) 
			      name:ZXAccountTotalDidChangeNotification 
			    object:nil];
	[defaultCenter addObserver:self 
			  selector:@selector(updateView:) 
			      name:ZXTransactionLabelDidChangeNotification 
			    object:nil];
	[defaultCenter addObserver:self 
			  selector:@selector(updateView:) 
			      name:ZXActiveAccountDidChangeNotification 
			    object:nil];
}

- (IBAction)updateView:(id)sender
{
	
	[self resetViewsPositions];

	[graphView removeAllSections];
	[textView removeAllSections];
	
	for(id label in [self.owner allLabels]) {
		if([label isEqual:[ZXLabelController noLabelObject]]) {
			continue;
		}
		id textColor = [label valueForKey:@"textColor"];
		id labelAmount = [NSNumber numberWithInt:0];
		id currentAccountName;
		
		// Default interval is from a distant past to now
		NSCalendarDate *calendarDate = [NSCalendarDate calendarDate];
		if([reportTimePopUpButton selectedTag] != ZXCustomReportTime) {
			self.reportStartDate = [NSDate distantPast];
			self.reportEndDate = [NSDate date];
		}
		switch([reportTimePopUpButton selectedTag]) {
			case ZXAllReportTime:
				break;
			case ZXThisMonthReportTime:
				self.reportStartDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] month:[calendarDate monthOfYear] day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
				break;
			case ZXLastMonthReportTime:
				self.reportStartDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] month:[calendarDate monthOfYear] - 1 day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
				self.reportEndDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] month:[calendarDate monthOfYear] day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
				break;
			case ZXThisYearReportTime:
				self.reportStartDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] month:1 day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
				break;
			case ZXLastYearReportTime:
				self.reportStartDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] - 1 month:1 day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
				self.reportEndDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] month:1 day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
				break;
			case ZXCustomReportTime:
			default:
				break;
		}
		
		NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Transaction" 
								     inManagedObjectContext:self.owner.managedObjectContext];
		NSPredicate *totalPredicate;
		NSFetchRequest *fetchRequest;
		NSError *error;
		NSArray *array;
		NSArray *dateArray = [NSArray arrayWithObjects:self.reportStartDate, self.reportEndDate, nil];
		switch([reportTypePopUpButton selectedTag]) {
			case ZXAllAccountsDepositsReportType:
			case ZXAllAccountsWithdrawalsReportType:
				totalPredicate = [NSPredicate predicateWithFormat:@"(transactionLabel.name like %@) AND (date BETWEEN %@)", [label valueForKey:@"name"], dateArray];
				
				fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
				[fetchRequest setEntity:entityDescription];
				[fetchRequest setPredicate:totalPredicate];
				error = nil;
				array = [self.owner.managedObjectContext executeFetchRequest:fetchRequest error:&error];
				if(array == nil) {
					// FIXME: Exception management to be done
					return;
				}
				if([reportTypePopUpButton selectedTag] == ZXAllAccountsDepositsReportType) {
					labelAmount = [array valueForKeyPath:@"@sum.deposit"];
				} else {
					labelAmount = [array valueForKeyPath:@"@sum.withdrawal"];
				}
				
				break;

			case ZXActiveAccountDepositsReportType:
			case ZXActiveAccountWithdrawalsReportType:
				currentAccountName = [self.owner.accountController valueForKeyPath:@"selection.name"];
				
				totalPredicate = [NSPredicate predicateWithFormat:@"(account.name like %@) AND (transactionLabel.name like %@) AND (date BETWEEN %@)", currentAccountName, [label valueForKey:@"name"], dateArray];
				
				fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
				[fetchRequest setEntity:entityDescription];
				[fetchRequest setPredicate:totalPredicate];
				error = nil;
				array = [self.owner.managedObjectContext executeFetchRequest:fetchRequest error:&error];
				if(array == nil) {
					// FIXME: Exception management to be done
					return;
				}
				if([reportTypePopUpButton selectedTag] == ZXActiveAccountDepositsReportType) {
					labelAmount = [array valueForKeyPath:@"@sum.deposit"];
				} else {
					labelAmount = [array valueForKeyPath:@"@sum.withdrawal"];
				}
				break;
			default:
				break;
		}
		id labelName = [label valueForKey:@"name"];
		
		ZXReportSection *section = [ZXReportSection sectionWithColor:textColor 
								      amount:labelAmount 
									name:labelName];
		[graphView addSection:section];
		[textView addSection:section];
		
		NSRect frame = [graphView frame];
		// Substracting the width added to the textView to the graphView
		frame.size.width -= textView.lastWidthModification.doubleValue;
		textView.lastWidthModification = [NSNumber numberWithInt:0];
		[graphView setFrame:frame];
		
	}
	
	[textView display];
	[graphView display];
	
}

// FIXME: Code from original Cashbox application. To be revised.
- (void) resetViewsPositions {
	
	// wtf?
	  float difference = 1 - [textView frame].size.width;
	
	// What is that?!
	NSRect frame = [textView frame];
	frame.size.width += difference; // is equal to frame.size.width = 1
	frame.origin.x -= difference; // is equal to frame.origin.x += [textView frame].size.width - 1;
	[textView setFrame:frame];
	// Frame of text view is modified to  have a width of 1 at the last pixel of previous frame
	
	// Change size of graph, that may be useful
	frame = [graphView frame];
	frame.size.width -= difference; // frame.size.width += [textView frame].size.width - 1;
	[graphView setFrame:frame];
	// The graph fills the freed space
}

- (IBAction)toggleDetailBox:(id)sender
{	
	NSRect frame = [reportWindow frame];
	frame.size.height += ([self.detailBoxHidden boolValue] ? 1: -1) * [detailBox frame].size.height;
	frame.origin.y += ([self.detailBoxHidden boolValue] ? -1: 1) * [detailBox frame].size.height;
	[[reportWindow animator] setFrame:frame display:YES];
	
	self.detailBoxHidden = [NSNumber numberWithBool:([self.detailBoxHidden boolValue] ? NO: YES)];
}

- (void)setValue:(id)newValue forKey:(id)key
{
	[super setValue:newValue forKey:key];
	if([key isEqual:@"reportStartDate"] || [key isEqual:@"reportEndDate"]) {
		[reportTimePopUpButton selectItemWithTag:ZXCustomReportTime];
		[self updateView:self];
	}
}

@end

