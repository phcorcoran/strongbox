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

// Test

@implementation ZXReportWindowController

@synthesize owner;

- (id)initWithOwner:(id)newOwner;
{
	self = [super init];
	self.owner = newOwner;
	return self;
}

- (void)showWindow
{
	if (!reportWindow) {
		[NSBundle loadNibNamed:@"ReportWindow" owner:self];
	}
	[self setupNotificationObserving];
	[self updateView:self];
	[reportWindow makeKeyAndOrderFront:nil];
}

- (void)setupNotificationObserving
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView:) name:ZXAccountTotalDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView:) name:ZXTransactionLabelDidChangeNotification object:nil];
	
//       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:ZXAllAccountsDidChangeNotification object:nil];
//       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:ZXAccountNameDidChangeNotification object:nil];
	
//      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:ZXActiveAccountDidChangeNotification object:nil];
        
}

- (IBAction)updateView:(id)sender
{
	
	[self resetViewsPositions];

	[graphView removeAllSections];
	[textView removeAllSections];
	
	for(id label in [self.owner allLabels]) {
		id textColor = [label valueForKey:@"textColor"];
		id labelAmount = [NSNumber numberWithInt:0];
		id currentAccountName;
		
		// Default interval is from a distant past to now
		NSDate *startDate = [NSDate distantPast], *endDate = [NSDate date];
		NSCalendarDate *calendarDate = [NSCalendarDate calendarDate];		
		switch([reportTimePopUpButton selectedTag]) {
			case ZXAllReportTime:
				break;
			case ZXThisMonthReportTime:
				startDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] month:[calendarDate monthOfYear] day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
				break;
			case ZXLastMonthReportTime:
				startDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] month:[calendarDate monthOfYear] - 1 day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
				endDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] month:[calendarDate monthOfYear] day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
				break;
			case ZXThisYearReportTime:
				startDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] month:1 day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
				break;
			case ZXLastYearReportTime:
				startDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] - 1 month:1 day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
				endDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] month:1 day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
				break;
			default:
				break;
		}
		
		NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Transaction" 
								     inManagedObjectContext:self.owner.managedObjectContext];
		NSPredicate *totalPredicate;
		NSFetchRequest *fetchRequest;
		NSError *error;
		NSArray *array;
		switch([reportTypePopUpButton selectedTag]) {
			case ZXAllAccountsDepositsReportType:
			case ZXAllAccountsWithdrawalsReportType:
				totalPredicate = [NSPredicate predicateWithFormat:@"(transactionLabel.name like %@) AND (date BETWEEN %@)", [label valueForKey:@"name"], [NSArray arrayWithObjects:startDate, endDate, nil]];
				
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
				
				totalPredicate = [NSPredicate predicateWithFormat:@"(account.name like %@) AND (transactionLabel.name like %@) AND (date BETWEEN %@)", currentAccountName, [label valueForKey:@"name"], [NSArray arrayWithObjects:startDate, endDate, nil]];
				
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
	
	[graphView display];
	[textView display];
}

- (IBAction)changeDollarPercent:(id)sender
{
	
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

/*- (IBAction)toggleRangePicker:(id)sender
{
	NSRect newFrame = [reportWindow frame];
	if([datePickerView isHidden]) {
		newFrame.size.height += datePickerView.frame.size.height;
		[datePickerView setHidden:NO];
		[[reportWindow animator] setFrame:newFrame];
	} else {
		newFrame.size.height -= datePickerView.frame.size.height;
		[datePickerView setHidden:YES];
		[[reportWindow animator] setFrame:newFrame];
	}
	
	newFrame.size.height += datePickerView.frame.size.height;
	[[reportWindow animator] setFrame:newFrame];
}*/

/*
- (void)accountTotalDidChange
{
	[self updateReportView];
	[self updateAllAccountStats];
}

- (void)prefereceWindowWillClose:(NSNotification *)notification
{
	[totals release];
	totals = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[PreferenceController sharedInstance]];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:reportWindow];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WYAccountTotalDidChangeNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WYAllAccountsDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WYAccountNameDidChangeNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WYActiveAccountDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WYTransactionLabelDidChangeNotification object:nil]; // should be just when a total changes or when a label changes
	
	reportWindow = nil;
}

- (IBAction)changeReportType:(id)sender
{
	[self updateReportView];
	[[NSUserDefaults standardUserDefaults] setObject:[select objectValue] forKey:ReportWindowViewSelection];
	[[NSUserDefaults standardUserDefaults] setObject:[selectTime objectValue] forKey:ReportWindowTimeSelection];
}

- (void)updateReportView
{
	NSArray *transactions = nil;
	SEL method = NULL;
	int counter;
	
	switch ([select indexOfSelectedItem])
	{
		// Deposit: active account
		case 0:
			account = [[AccountController sharedInstance] activeAccount];
			//			[[NSNotificationCenter defaultCenter] removeObserver:self name:WYAccountTotalDidChangeNotification object:nil];
			//			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReportView) name:WYAccountTotalDidChangeNotification object:account];
			transactions = [account allTransactions];
			method = @selector(deposit);
			break;
		// Withdrawal: active account
		case 1:
			account = [[AccountController sharedInstance] activeAccount];
			//			[[NSNotificationCenter defaultCenter] removeObserver:self name:WYAccountTotalDidChangeNotification object:nil];
			//			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReportView) name:WYAccountTotalDidChangeNotification object:account];
			transactions = [account allTransactions];
			method = @selector(withdrawal);
			break;
		// Deposit: all account
		case 3:
			//			[[NSNotificationCenter defaultCenter] removeObserver:self name:WYAccountTotalDidChangeNotification object:nil];
			//			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReportView) name:WYAccountTotalDidChangeNotification object:nil];
			for (counter = 0; counter < [[[AccountController sharedInstance] allAccounts] count]; counter++)
			{
				transactions = [[[[[AccountController sharedInstance] allAccounts] objectAtIndex:counter] allTransactions] arrayByAddingObjectsFromArray:transactions];
			}
			method = @selector(deposit);
			break;
		// Withdrawal: all account
		case 4:
			//			[[NSNotificationCenter defaultCenter] removeObserver:self name:WYAccountTotalDidChangeNotification object:nil];
			//			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReportView) name:WYAccountTotalDidChangeNotification object:nil];
			for (counter = 0; counter < [[[AccountController sharedInstance] allAccounts] count]; counter++)
			{
				transactions = [[[[[AccountController sharedInstance] allAccounts] objectAtIndex:counter] allTransactions] arrayByAddingObjectsFromArray:transactions];
			}
			method = @selector(withdrawal);
			break;
		default:
			break;
	}
	
	NSCalendarDate *compareDate = nil;
	NSCalendarDate *calendarDate = [NSCalendarDate calendarDate];
	NSMutableArray *temp = [[NSMutableArray alloc] init];//transactions;
	switch ([selectTime indexOfSelectedItem])
	{
		case 0:
			break;
		case 1:
			for (counter = 0; counter < [transactions count]; counter++)
			{
				compareDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] month:[calendarDate monthOfYear] day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
				if ([[[transactions objectAtIndex:counter] date] compare:compareDate] != NSOrderedAscending)
				{
					compareDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] month:[calendarDate monthOfYear] + 1 day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
					if ([[[transactions objectAtIndex:counter] date] compare:compareDate] == NSOrderedAscending)
					{
						[temp addObject:[transactions objectAtIndex:counter]];
					}
				}
			}
			transactions = temp;
			break;
			case 2:
			for (counter = 0; counter < [transactions count]; counter++)
			{
				compareDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] month:[calendarDate monthOfYear] - 1 day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
				if ([[[transactions objectAtIndex:counter] date] compare:compareDate] != NSOrderedAscending)
				{
					compareDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] month:[calendarDate monthOfYear] day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
					if ([[[transactions objectAtIndex:counter] date] compare:compareDate] == NSOrderedAscending)
					{
						[temp addObject:[transactions objectAtIndex:counter]];
					}
				}
			}
			transactions = temp;
			break;
			case 3:
			for (counter = 0; counter < [transactions count]; counter++)
			{
				compareDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] month:1 day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
				if ([[[transactions objectAtIndex:counter] date] compare:compareDate] != NSOrderedAscending)
				{
					compareDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] + 1 month:1 day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
					if ([[[transactions objectAtIndex:counter] date] compare:compareDate] == NSOrderedAscending)
					{
						[temp addObject:[transactions objectAtIndex:counter]];
					}
				}
			}
			transactions = temp;
			break;
			case 4:
			for (counter = 0; counter < [transactions count]; counter++)
			{
				compareDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] - 1 month:1 day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
				if ([[[transactions objectAtIndex:counter] date] compare:compareDate] != NSOrderedAscending)
				{
					compareDate = [NSCalendarDate dateWithYear:[calendarDate yearOfCommonEra] month:1 day:1 hour:0 minute:0 second:0 timeZone:[calendarDate timeZone]];
					if ([[[transactions objectAtIndex:counter] date] compare:compareDate] == NSOrderedAscending)
					{
						[temp addObject:[transactions objectAtIndex:counter]];
					}
				}
			}
			transactions = temp;
			break;
			default:
			break;
	}
	
	labels = [[LabelController sharedInstance] labelSet];
	[totals release];
	totals = [[NSMutableArray alloc] init];
	total = 0;
	
	for (counter = 0; counter < [labels numberOfItems]; counter++)
	{
		[totals addObject:[NSNumber numberWithDouble:0.0]];
	}
	
	for (counter = 0; counter < [transactions count]; counter++)
	{
		WYTransaction *transaction = [transactions objectAtIndex:counter];
		int index = [labels indexOfLabel:[transaction label]];
		if (index != NSNotFound)
		{
			if (method == @selector(deposit))
			{
				double new = [[totals objectAtIndex:index] doubleValue] + [transaction deposit];
				[totals replaceObjectAtIndex:index withObject:[NSNumber numberWithDouble:new]];
				//				totals[index] += [transaction deposit];
				total += [transaction deposit];				
			} else {
				double new = [[totals objectAtIndex:index] doubleValue] + [transaction withdrawal];
				[totals replaceObjectAtIndex:index withObject:[NSNumber numberWithDouble:new]];
				//				totals[index] += [transaction withdrawal];
				total += [transaction withdrawal];
			}
		}
	}
	
	[temp release];
	[reportView removeAllSections];
	
	for (counter = 0; counter < [labels numberOfItems]; counter++)
	{
		if ([[totals objectAtIndex:counter] doubleValue] > 0)
		{
			double percent = [[totals objectAtIndex:counter] doubleValue] / total;
			NSColor *color = [[labels labelAtIndex:counter] textColor];
			[reportView addSectionColor:color percent:percent];
		}
	}
	[self recreateTextView];
	[reportWindow display];
}

- (void)recreateTextView
{
	float difference = 1 - [reportTextView frame].size.width;
	NSRect frame = [reportTextView frame];
	frame.size.width += difference;
	frame.origin.x -= difference;
	[reportTextView setFrame:frame];
	
	frame = [reportView frame];
	frame.size.width -= difference;
	[reportView setFrame:frame];	
	
	while ([[reportTextView subviews] count] > 0)
	{
		[[[reportTextView subviews] objectAtIndex:0] removeFromSuperview];
	}
	int counter;
	int number_added = 0;
	for (counter = 0; counter < [labels numberOfItems]; counter++)
	{
		if ([[totals objectAtIndex:counter] doubleValue] > 0)
		{
			NSString *name = [[labels labelAtIndex:counter] name];
			double percent = [[totals objectAtIndex:counter] doubleValue] / total;
			NSColor *color = [[labels labelAtIndex:counter] textColor];
			
			NSTextField *text = [[NSTextField alloc] initWithFrame:NSMakeRect(0,0,600,20)];
			[text setBordered:NO];
			[text setEditable:NO];
			[text setSelectable:NO];
			[text setDrawsBackground:NO];
			
			NSString *content;
			if (showPercents) {
				content = [NSString stringWithFormat:@"%@: %0.1f%%", name, percent * 100];
			} else {
				// this all doesn't seem necessary, but we create a text field, apply a format, take the string value
				// from the text field, then release the text field
				NSMutableString *positive = [NSMutableString stringWithString:[[NSUserDefaults standardUserDefaults] objectForKey:NSPositiveCurrencyFormatString]];
				[positive replaceOccurrencesOfString:@"999" withString:@"##0" options:0 range:[positive rangeOfString:positive]];
				[positive replaceOccurrencesOfString:@"9" withString:@"#" options:0 range:[positive rangeOfString:positive]];
				NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
				[format setFormat:[NSString stringWithFormat:@"%@", positive]];
				[format setLocalizesFormat:YES];
				NSTextField *temp = [[NSTextField alloc] init];
				[temp setDoubleValue:[[totals objectAtIndex:counter] doubleValue]];
				[temp setFormatter:format];
				[format release];
				
				content = [NSString stringWithFormat:@"%@: %@", name, [temp stringValue]];
				[temp release];
			}
			NSAttributedString *string = [[NSAttributedString alloc] initWithString:content
										     attributes:[NSDictionary dictionaryWithObjectsAndKeys:color, @"NSColor", nil, nil]];
			[text setAttributedStringValue:string];
			[string release];
			
			[text sizeToFit];
			frame = [text frame];
			frame.size.width += 5;
			frame.origin.y = [reportTextView frame].size.height - 14 * ++number_added;
			frame.origin.x = [reportTextView frame].size.width - [text frame].size.width;
			[text setFrame:frame];
			[reportTextView addSubview:text];
			[text setAutoresizingMask:NSViewMinYMargin | NSViewMinXMargin];
			[text release];
			
			if ([reportTextView frame].size.width < [text frame].size.width)
			{
				float difference = [text frame].size.width - [reportTextView frame].size.width;
				frame = [reportTextView frame];
				frame.size.width += difference;
				frame.origin.x -= difference;
				[reportTextView setFrame:frame];
				
				frame = [reportView frame];
				frame.size.width -= difference;
				[reportView setFrame:frame];
			}
		}
	}
}

- (IBAction)changeDollarPercent:(id)sender
{
	showPercents = !showPercents;
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:showPercents] forKey:DOLLAR_PERCENT];
	[self recreateTextView];
	[reportWindow display];
}

- (void)updateAllAccountStats
{
	int counter;
	float min_width = 50;
	NSRect frame;
	
	while ([[allAccounts subviews] count] > 0)
	{
		[[[allAccounts subviews] objectAtIndex:0] removeFromSuperview];
	}
	
	NSNumberFormatter *format = [[PreferenceController sharedInstance] objectForKey:WYStatFormatter];
	
	NSTextField *title = [[NSTextField alloc] init];
	[allAccounts addSubview:title];
	[title release];
	[title setBordered:NO];
	[title setEditable:NO];
	[title setSelectable:NO];
	[title setDrawsBackground:NO];
	[title setStringValue:[NSString stringWithString:[[NSBundle mainBundle] localizedStringForKey:@"Calculating..." value:nil table:nil]]];
	[title setFrame:NSMakeRect(20, [allAccounts frame].size.height - 18, 164, 17)];
	[title setAutoresizingMask:NSViewMinYMargin];
	
	float heightChange = ([[[AccountController sharedInstance] allAccounts] count] + 2) * 17 + 29 - [allAccounts frame].size.height;
	frame = [allAccounts frame];
	frame.size.height += heightChange;
	[allAccounts setFrame:frame];
	
	frame = [reportView frame];
	frame.size.height -= heightChange;
	frame.origin.y += heightChange;
	[reportView setFrame:frame];
	
	frame = [reportTextView frame];
	frame.size.height -= heightChange;
	frame.origin.y += heightChange;
	[reportTextView setFrame:frame];
	
	frame = [divider frame];
	frame.origin.y += heightChange;
	[divider setFrame:frame];
	
	[reportWindow setMinSize:NSMakeSize([reportWindow minSize].width, [reportWindow minSize].height + heightChange)];
	
        
	double tot = 0;
	for (counter = 0; counter < [[[AccountController sharedInstance] allAccounts] count]; counter++)
	{
		int index = [[[AccountController sharedInstance] allAccounts] count] - 1 - counter;
		
		frame.size.height = 17;
		frame.size.width = 215;
		frame.origin.x = 32;
		frame.origin.y = 17 * (counter + 2);
		
		NSTextField *new = [[NSTextField alloc] init];
		[allAccounts addSubview:new];
		[new release];
		[new setBordered:NO];
		[new setEditable:NO];
		[new setSelectable:NO];
		[new setDrawsBackground:NO];
		[new setStringValue:[[[[AccountController sharedInstance] allAccounts] objectAtIndex:index] name]];
		[new setFrame:frame];
		[new sizeToFit];
		
		NSTextField *number = [[NSTextField alloc] init]; 
		[allAccounts addSubview:number];
		[number release];
		[number setBordered:NO];
		[number setEditable:NO];
		[number setSelectable:NO];
		[number setDrawsBackground:NO];
		[number setFormatter:format];
		[number setDoubleValue:[(WYAccount *)[[[AccountController sharedInstance] allAccounts] objectAtIndex:index] total]];
		[number setAutoresizingMask:NSViewMinXMargin];
		[formatted_text_fields addObject:number];
		
		[number sizeToFit];     
		frame.origin.x =  [allAccounts frame].size.width - [number frame].size.width - 32;
		frame.size.width = [number frame].size.width + 1;
		[number setFrame:frame];
		
		frame.origin.x = 32 + [new frame].size.width;
		frame.size.width = [number frame].origin.x - frame.origin.x;
		
		NSTextField *connect = [[NSTextField alloc] init]; 
		[allAccounts addSubview:connect];
		[connect release];
		[connect setBordered:NO];
		[connect setEditable:NO];
		[connect setSelectable:NO];
		[connect setDrawsBackground:NO];
		[connect setStringValue:@" . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . "];
		[connect setAutoresizingMask:NSViewWidthSizable];
		[connect setFrame:frame];
		
		min_width = (min_width > [number frame].size.width + [new frame].size.width)?min_width:[number frame].size.width + [new frame].size.width;
		tot = tot + [(WYAccount *)[[[AccountController sharedInstance] allAccounts] objectAtIndex:index] total];
	}
	
	NSTextField *total_field = [[NSTextField alloc] init];
	[allAccounts addSubview:total_field];
	[total_field release];
	[total_field setBordered:NO];
	[total_field setEditable:NO];
	[total_field setSelectable:NO];
	[total_field setDrawsBackground:NO];
	[total_field setStringValue:[[NSBundle mainBundle] localizedStringForKey:@"Total:  " value:nil table:nil]];
	
	[total_field sizeToFit];
	frame = [total_field frame];
	frame.size.height = 17;
	frame.origin.x = 32;
	frame.origin.y = 0;
	[total_field setFrame:frame];
	
	NSTextField *total_number_field = [[NSTextField alloc] init]; 
	[allAccounts addSubview:total_number_field];
	[total_number_field release];
	[total_number_field setBordered:NO];
	[total_number_field setEditable:NO];
	[total_number_field setSelectable:NO];
	[total_number_field setDrawsBackground:NO];
	[total_number_field setFormatter:format];
	[total_number_field setObjectValue:[NSNumber numberWithDouble:tot]];
	[formatted_text_fields addObject:total_number_field];
	
	[total_number_field sizeToFit];
	frame = [total_number_field frame];
	frame.size.height = 17;
	frame.origin.x = 32 + [total_field frame].size.width;
	frame.origin.y = 0;
	[total_number_field setFrame:frame];
	
	[title setStringValue:[[NSBundle mainBundle] localizedStringForKey:@"Statistics for all accounts:" value:nil table:nil]];
}
*/
@end

