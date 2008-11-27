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

/* ReportWindowController */

#if PATATE

#import "ReportWindowController.h"
#import "LabelController.h"
#import "WYReportView.h"
#import "PreferenceController.h"
#import "AccountController.h"
#import "WYClickView.h"

#define ReportWindowViewSelection   @"Report Window View Selection"
#define ReportWindowTimeSelection   @"Report Window Time Selection"
#define DOLLAR_PERCENT			@"Show Percents in Report Window"

@interface ReportWindowController (PRIVATE)
- (void)updateReportView;
- (void)updateAllAccountStats;
- (void)recreateTextView;
- (void)accountTotalDidChange;
@end

@implementation ReportWindowController


static ReportWindowController *sharedInstance = nil;
+ (ReportWindowController *)sharedInstance {
    return sharedInstance ? sharedInstance : [[self alloc] init];
}

- (id)init
{
    if (sharedInstance) { // We just have one instance of the class, return that one instead
        [self release];
    } else if (self = [super init]) {
		formatted_text_fields = [[NSMutableArray alloc] init];
		id pref = [[NSUserDefaults standardUserDefaults] objectForKey:DOLLAR_PERCENT];
		if (pref) { showPercents = [pref boolValue]; }
		else { showPercents = TRUE; }
        sharedInstance = self;
    }
    return sharedInstance;
}

- (void)dealloc
{
	[formatted_text_fields release];
	[super dealloc];
}

- (void)showWindowForAccount:(WYAccount *)account
{
	if (!reportWindow)
	{
		[NSBundle loadNibNamed:@"ReportWindow" owner:self];
		[reportWindow setTitle:NSLocalizedString(@"Reports", nil)];
		id pref = [[NSUserDefaults standardUserDefaults] objectForKey:ReportWindowViewSelection];
		if (pref) { [select setObjectValue:pref]; }
		pref = [[NSUserDefaults standardUserDefaults] objectForKey:ReportWindowTimeSelection];
		if (pref) { [selectTime setObjectValue:pref]; }

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prefChange:) name:nil object:[PreferenceController sharedInstance]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prefereceWindowWillClose:) name:NSWindowWillCloseNotification object:reportWindow];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountTotalDidChange) name:WYAccountTotalDidChangeNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAllAccountStats) name:WYAllAccountsDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAllAccountStats) name:WYAccountNameDidChangeNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReportView) name:WYActiveAccountDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReportView) name:WYTransactionLabelDidChangeNotification object:nil];
	}
	[self updateReportView];
	[self updateAllAccountStats];
	[reportWindow makeKeyAndOrderFront:nil];
}

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

// This method somehow creates the report view
- (void)updateReportView
{
	WYAccount *account;
	NSArray *transactions = nil;
	SEL method = NULL;
	int counter;
	
	switch ([select indexOfSelectedItem])
	{
		// Active account deposit
		case 0:
			account = [[AccountController sharedInstance] activeAccount];
//			[[NSNotificationCenter defaultCenter] removeObserver:self name:WYAccountTotalDidChangeNotification object:nil];
//			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReportView) name:WYAccountTotalDidChangeNotification object:account];
			transactions = [account allTransactions];
			method = @selector(deposit);
			break;
		// Active account withdrawal
		case 1:
			account = [[AccountController sharedInstance] activeAccount];
//			[[NSNotificationCenter defaultCenter] removeObserver:self name:WYAccountTotalDidChangeNotification object:nil];
//			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReportView) name:WYAccountTotalDidChangeNotification object:account];
			transactions = [account allTransactions];
			method = @selector(withdrawal);
			break;
		// All accounts deposit
		case 3:
//			[[NSNotificationCenter defaultCenter] removeObserver:self name:WYAccountTotalDidChangeNotification object:nil];
//			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReportView) name:WYAccountTotalDidChangeNotification object:nil];
			for (counter = 0; counter < [[[AccountController sharedInstance] allAccounts] count]; counter++)
			{
				transactions = [[[[[AccountController sharedInstance] allAccounts] objectAtIndex:counter] allTransactions] arrayByAddingObjectsFromArray:transactions];
			}
			method = @selector(deposit);
			break;
		// All accounts withdrawal
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
		// All time?
		case 0:
			break;
		// This month
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
		// Last month
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
		// This year
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
		// Last year
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
	// totals is the array containing the sum for each label I guess
	// total is (not misleadingly) an important class variable
	total = 0;
	
	// Clear totals
	for (counter = 0; counter < [labels numberOfItems]; counter++)
	{
		[totals addObject:[NSNumber numberWithDouble:0.0]];
	}
	
	// for each transaction (oh my god, this it a lot)
	for (counter = 0; counter < [transactions count]; counter++)
	{
		WYTransaction *transaction = [transactions objectAtIndex:counter];
		int index = [labels indexOfLabel:[transaction label]];
		if (index != NSNotFound)
		{
			// Wow, using a selector was a bad idea after all. A string / a integer would be better
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

	// recreate pie chart
	for (counter = 0; counter < [labels numberOfItems]; counter++)
	{
		if ([[totals objectAtIndex:counter] doubleValue] > 0)
		{
			double percent = [[totals objectAtIndex:counter] doubleValue] / total;
			NSColor *color = [[labels labelAtIndex:counter] textColor];
			[reportView addSectionColor:color percent:percent];
		}
	}
	// Manage the text view
	[self recreateTextView];
	[reportWindow display];
}

// Used to create the text view
- (void)recreateTextView
{
	// Wtf is that for?
	float difference = 1 - [reportTextView frame].size.width;
	// nice ordering
	NSRect frame = [reportTextView frame];
	// that's clear
	frame.size.width += difference; // frame.size.width = 1
	frame.origin.x -= difference;
	[reportTextView setFrame:frame];

	frame = [reportView frame];
	frame.size.width -= difference;
	[reportView setFrame:frame];	
	
	// clear all subviews (erase text)
    while ([[reportTextView subviews] count] > 0)
    {
        [[[reportTextView subviews] objectAtIndex:0] removeFromSuperview];
    }
	
	int counter;
	int number_added = 0;
	// for each label (not bad)
	for (counter = 0; counter < [labels numberOfItems]; counter++)
	{
		// for each NSNumber in totals
		if ([[totals objectAtIndex:counter] doubleValue] > 0)
		{
			NSString *name = [[labels labelAtIndex:counter] name];
			// Divide by mysterious class variable
			double percent = [[totals objectAtIndex:counter] doubleValue] / total;
			NSColor *color = [[labels labelAtIndex:counter] textColor];
			
			// Magic number
			NSTextField *text = [[NSTextField alloc] initWithFrame:NSMakeRect(0,0,600,20)];
			[text setBordered:NO];
			[text setEditable:NO];
			[text setSelectable:NO];
			[text setDrawsBackground:NO];

			NSString *content;
			if (showPercents) {
				// Hard-coded formatter
				content = [NSString stringWithFormat:@"%@: %0.1f%%", name, percent * 100];
			} else {
				// this all doesn't seem necessary, but we create a text field, apply a format, take the string value
				// from the text field, then release the text field
				// Still more magic
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
			// We definitely like magic numbers
			frame.size.width += 5;
			// Yay, wtf is 14?
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

- (void)prefChange:(NSNotification *)notification
{
    NSNumberFormatter *format = [[PreferenceController sharedInstance] objectForKey:WYStatFormatter];
    int counter;
    for (counter = 0; counter < [formatted_text_fields count]; counter++)
    {
        NSTextField *field = [formatted_text_fields objectAtIndex:counter];
		[field setFormatter:format];
        [field updateCell:[field cell]];
    }
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
@end

#endif
