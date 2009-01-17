/*
 * Name: 	ZXReportWindowController.m
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

#import "ZXReportWindowController.h"
#import "ZXDocument.h"
#import "ZXLabelController.h"
#import "ZXNotifications.h"
#import "ZXReportGraphView.h"
#import "ZXReportHistView.h"
#import "ZXReportSection.h"
#import "ZXReportTextView.h"


@interface ZXReportWindowController (Private)
- (void)parseReportDates;
- (NSNumber *)parseLabelAmount:(id)label;
- (void)setupNotificationObserving;
- (void)resetViewsPositions;
@end

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
	//[histView removeAllSections];
	
	[self parseReportDates];
	for(id label in [self.owner allLabels]) {
		if([[label valueForKey:@"isImmutable"] boolValue]) continue;
		id textColor = [label valueForKey:@"textColor"];
		id labelAmount;
		id labelName = [label valueForKey:@"name"];
		
		labelAmount = [self parseLabelAmount:label];
		double v = [labelAmount doubleValue];
		if(-0.001 < v && v < 0.001) continue;
		
		ZXReportSection *section = [ZXReportSection sectionWithColor:textColor 
								      amount:labelAmount 
									name:labelName];
		[graphView addSection:section];
		//[histView addSection:section];
		[textView addSection:section];
		
		NSRect frame = [graphView frame];
		// Substracting the width added to the textView to the graphView
		frame.size.width -= textView.lastWidthModification.doubleValue;
		textView.lastWidthModification = [NSNumber numberWithInt:0];
		[graphView setFrame:frame];
	}
	
	[textView display];
	[graphView display];
	//[histView display];
}

- (NSNumber *)parseLabelAmount:(id)label
{
	id currentAccountName, curAccount;
	id labelAmount = [NSNumber numberWithInt:0];
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
			totalPredicate = [NSPredicate predicateWithFormat:@"(transactionLabel == %@) AND (date BETWEEN %@)", label, dateArray];
			
			fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
			[fetchRequest setEntity:entityDescription];
			[fetchRequest setPredicate:totalPredicate];
			error = nil;
			array = [self.owner.managedObjectContext executeFetchRequest:fetchRequest error:&error];
			if(array == nil) {
				// FIXME: Exception management to be done
				return nil;
			}
			if([reportTypePopUpButton selectedTag] == ZXAllAccountsDepositsReportType) {
				labelAmount = [array valueForKeyPath:@"@sum.deposit"];
			} else {
				labelAmount = [array valueForKeyPath:@"@sum.withdrawal"];
			}
			
			break;
			
		case ZXActiveAccountDepositsReportType:
		case ZXActiveAccountWithdrawalsReportType:
			curAccount = [self.owner.accountController valueForKeyPath:@"selection.self"];
			currentAccountName = [curAccount valueForKey:@"name"];
			
			totalPredicate = [NSPredicate predicateWithFormat:@"(account == %@) AND (transactionLabel == %@) AND (date BETWEEN %@)", curAccount, label, dateArray];
			
			fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
			[fetchRequest setEntity:entityDescription];
			[fetchRequest setPredicate:totalPredicate];
			error = nil;
			array = [self.owner.managedObjectContext executeFetchRequest:fetchRequest error:&error];
			if(array == nil) {
				// FIXME: Exception management to be done
				return nil;
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
	return labelAmount;
}

- (void)parseReportDates
{
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
	NSLog(@"Setting %@", key);
	if([key isEqual:@"reportStartDate"] || [key isEqual:@"reportEndDate"]) {
		[reportTimePopUpButton selectItemWithTag:ZXCustomReportTime];
		[self updateView:self];
		NSLog(@"Updating.");
	}
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end

