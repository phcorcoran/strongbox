/*
 * Name: 	ZXPrintTransactionView.m
 * Project:	Cashbox
 * Created on:	2008-11-30
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

#import "ZXPrintTransactionView.h"
#import "ZXDocument.h"
#import "ZXCurrencyFormatter.h"


#define VSPACE 14.0

@implementation ZXPrintTransactionView
- (id)initWithOwner:(ZXDocument *)newOwner
{
	NSRange pageRange;
	NSRect frame;
	owner = newOwner;
	paperSize = [[owner printInfo] paperSize];
	topMargin = [[owner printInfo] topMargin];
	leftMargin = [[owner printInfo] leftMargin];
	[self knowsPageRange:&pageRange];
	frame = NSUnionRect([self rectForPage:pageRange.location], [self rectForPage:NSMaxRange(pageRange)-1]);
	
	[super initWithFrame:frame];
	
	titleRect = [self rectForTransaction:0];
	titleRect.size.height = 2*VSPACE;
	subtitleRect = [self rectForTransaction:2];
	subtitleRect.size.height = 2*VSPACE;
	
	attributes = [[NSMutableDictionary alloc] init];
	[attributes setObject:[NSFont fontWithName:@"Helvetica" size:10.0] 
		       forKey:NSFontAttributeName];
	
	rightStyle = [[NSMutableParagraphStyle alloc] init];
	[rightStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
	[rightStyle setAlignment:NSRightTextAlignment];
	centeredStyle = [[NSMutableParagraphStyle alloc] init];
	[centeredStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
	[centeredStyle setAlignment:NSCenterTextAlignment];
	return self;	
}

- (BOOL)isFlipped
{
	return YES;
}

- (NSRect)rectForPage:(int)page
{
	NSRect result;
	result.size = paperSize;
	
	result.origin.y = (page - 1) * paperSize.height;
	result.origin.x = 0.0;
	return result;
}

- (int)transactionsPerPage
{
	float tpp = (paperSize.height - (2.0 * topMargin)) / VSPACE;
	return (int)tpp;
}

- (BOOL)knowsPageRange:(NSRange *)r
{
	int transactionPerPage = [self transactionsPerPage];
	int count = [[owner.transactionController arrangedObjects] count] + 4;
	r->location = 1;
	r->length = (count / transactionPerPage);
	if(count % transactionPerPage > 0) {
		r->length += 1;
	}
	return YES;
	
}

- (NSRect)rectForTransaction:(int)i
{
	NSRect result;
	int transactionPerPage = [self transactionsPerPage];
	result.size.height = VSPACE;
	result.size.width = paperSize.width - (2*leftMargin);
	result.origin.x = leftMargin;
	int page = i / transactionPerPage;
	int indexOnPage = i % transactionPerPage;
	result.origin.y = (page * paperSize.height) + topMargin + (indexOnPage * VSPACE);
	return result;
}

- (void)drawRect:(NSRect)r
{
	int count, i;
	NSArray *arr = [owner.transactionController arrangedObjects];
	NSDateFormatter *df = owner.dateFormatter;
	NSNumberFormatter *nf = [ZXCurrencyFormatter currencyFormatter];
	
	if(NSIntersectsRect(r, titleRect)) {
		id titleAttributes = [[NSMutableDictionary alloc] init];
		[titleAttributes setObject:[NSFont fontWithName:@"Helvetica" size:22.0] 
			       forKey:NSFontAttributeName];
		[titleAttributes setObject:centeredStyle forKey:NSParagraphStyleAttributeName];
		NSString *name = [owner.accountController valueForKeyPath:@"selection.name"];
		[name drawInRect:titleRect withAttributes:titleAttributes];
		[titleAttributes release];
		
	}
	if(NSIntersectsRect(r, subtitleRect)) {
		id subtitleAttributes = [[NSMutableDictionary alloc] init];
		[subtitleAttributes setObject:[NSFont fontWithName:@"Helvetica" size:11.0] 
				    forKey:NSFontAttributeName];
		[subtitleAttributes setObject:centeredStyle forKey:NSParagraphStyleAttributeName];
		// FIXME: Hard-coded english
		NSString *name = [NSString stringWithFormat:@"As of %@", [df stringFromDate:[NSDate date]]];
		[name drawInRect:subtitleRect withAttributes:subtitleAttributes];
		[subtitleAttributes release];
	}
	
	count = [arr count];
	for(i = 0; i < count; i++) {
		NSRect txRect = [self rectForTransaction:i + 4];
		if(NSIntersectsRect(r, txRect)) {
			float wText = txRect.size.width - 270;
			if(wText < 0) wText = 0;
			id obj = [arr objectAtIndex:i];
			
			NSColor *c = [obj valueForKeyPath:@"transactionLabel.textColor"];
			NSRect tmp;
			double v;
			float x = txRect.origin.x, a = 0;
			
			id colorAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
			if(c != nil) {
				[colorAttributes setObject:c forKey:NSForegroundColorAttributeName];
			}
			
			a = 60.0;
			id date = [df stringFromDate:[obj valueForKey:@"date"]];
			tmp = NSMakeRect(x, txRect.origin.y, a, txRect.size.height);
			[date drawWithRect:tmp options:NSLineBreakByTruncatingTail attributes:colorAttributes];
			x += a + 10.0;
			
			a = 2*wText / 5;
			id labelName = [obj valueForKeyPath:@"transactionLabel.name"];
			tmp = NSMakeRect(x, txRect.origin.y, a, txRect.size.height);
			[labelName drawWithRect:tmp options:NSLineBreakByTruncatingTail attributes:colorAttributes];
			x += a + 10.0;
			
			a = wText - a;
			id desc = [obj valueForKey:@"transactionDescription"];
			tmp = NSMakeRect(x, txRect.origin.y, a, txRect.size.height);
			[desc drawWithRect:tmp options:NSLineBreakByTruncatingTail attributes:colorAttributes];
			x += a + 10.0;
			
			a = 50.0;
			v = [[obj valueForKey:@"withdrawal"] doubleValue];
			if(!(-0.001 < v && v < 0.001)) {
				id withdrawal = [nf stringFromNumber:[obj valueForKey:@"withdrawal"]];
				tmp = NSMakeRect(x, txRect.origin.y, a, txRect.size.height);
				[withdrawal drawWithRect:tmp options:NSLineBreakByTruncatingTail attributes:attributes];
			}
			x += a + 10.0;
			
			a = 50.0;
			v = [[obj valueForKey:@"deposit"] doubleValue];
			if(!(-0.001 < v && v < 0.001)) {
				id deposit = [nf stringFromNumber:[obj valueForKey:@"deposit"]];
				tmp = NSMakeRect(x, txRect.origin.y, a, txRect.size.height);
				[deposit drawWithRect:tmp options:NSLineBreakByTruncatingTail attributes:attributes];
			}
			x += a + 10.0;
			
			a = 60.0;
			if([[obj valueForKey:@"balance"] doubleValue] < 0) {
				[colorAttributes setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
			} else {
				[colorAttributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
			}
			[colorAttributes setObject:rightStyle forKey:NSParagraphStyleAttributeName];
			id balance = [nf stringFromNumber:[obj valueForKey:@"balance"]];
			tmp = NSMakeRect(x, txRect.origin.y, a, txRect.size.height);
			[balance drawWithRect:tmp options:NSLineBreakByTruncatingTail attributes:colorAttributes];
		}
	}
	
}

- (void)dealloc
{
	[attributes release];
	[centeredStyle release];
	[rightStyle release];
	[super dealloc];
}

/*
- (void)print:(id)sender
{
	NSTextField *text = [[[NSTextField alloc] init] autorelease];
	[text setBordered:NO];
	[text setEditable:NO];
	[text setSelectable:NO];
	[text setDrawsBackground:NO];
	[text setFont:[NSFont systemFontOfSize:24]];
	[text setStringValue:[[[AccountController sharedInstance] activeAccount] name]];
	[text sizeToFit];
	
	NSTextField *text_two = [[[NSTextField alloc] init] autorelease];
	[text_two setBordered:NO];
	[text_two setEditable:NO];
	[text_two setSelectable:NO];
	[text_two setDrawsBackground:NO];
	[text_two setStringValue:@"As of"];
	[text_two sizeToFit];
	
	NSTextField *date = [[[NSTextField alloc] init] autorelease];
	[date setBordered:NO];
	[date setEditable:NO];
	[date setSelectable:NO];
	[date setDrawsBackground:NO];
	[date setFormatter:[[PreferenceController sharedInstance] objectForKey:WYDateFormatter]];
	[date setObjectValue:[NSCalendarDate calendarDate]];
	[date sizeToFit];
	
	NSTableView *table = [[[NSTableView alloc] init] autorelease];
	[table setDelegate:self];
	[table setDataSource:self];
	[table setIntercellSpacing:NSMakeSize(0,[table intercellSpacing].height)];
	
	int counter;
	float total_width = 0;
	for (counter = 0; counter < [[view tableColumns] count]; counter ++)
	{
		if (![[[[view tableColumns] objectAtIndex:counter] identifier] isEqualToString:RECONCILED_COL])
		{
			NSTableColumn *user_def = [[view tableColumns] objectAtIndex:counter];
			NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier:[[user_def identifier] copy]];
			[table addTableColumn:col];
			[col release];
			[col setWidth:[user_def width]];
			[col setMinWidth:[user_def minWidth]];
			[col setMaxWidth:[user_def maxWidth]];
			total_width += [user_def width];
			if ([[user_def dataCell] isKindOfClass:[WYOvalTextFieldCell class]]) // don't draw labels while printing
			{
				[col setDataCell:[[NSTextFieldCell alloc] init]];
				[[col dataCell] release];
				[[col dataCell] setFormatter:[[user_def dataCell] formatter]];
				[[col dataCell] setAlignment:[[user_def dataCell] alignment]];
				[[col dataCell] setFont:[[user_def dataCell] font]];
			} else {
				[col setDataCell:[[user_def dataCell] copy]];
				[[col dataCell] release];
			}
		} else {
			NSTableColumn *user_def = [[view tableColumns] objectAtIndex:counter];
			NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier:RECONCILED_PRINT_COL];
			[table addTableColumn:col];
			[col release];
			[col setWidth:[user_def width]];
			[col setMinWidth:[user_def minWidth]];
			[col setMaxWidth:[user_def maxWidth]];
			total_width += [user_def width];
			[[col dataCell] setAlignment:NSCenterTextAlignment];
			[[col dataCell] setFont:[NSFont systemFontOfSize:11]];
		}
	}
	for (counter = 0; counter < [[table tableColumns] count]; counter++)
	{
		NSTableColumn *col = [[table tableColumns] objectAtIndex:counter];
		[col setWidth:[col width] * (550 / total_width)];
	}
	
	[table reloadData];
	
	NSView *print_view = [[[NSView alloc] init] autorelease];
	[print_view setFrame:NSMakeRect(0,0,600,18*[table_contents count] + 80)];
	
	[print_view addSubview:table];
	[print_view addSubview:text];
	[print_view addSubview:text_two];
	[print_view addSubview:date];
	[text setFrame:NSMakeRect((600 - [text frame].size.width) / 2, 18*[table_contents count] + 42, [text frame].size.width, [text frame].size.height)];
	[text_two setFrame:NSMakeRect((600 - [text_two frame].size.width - [date frame].size.width) / 2, 18*[table_contents count] + 24, [text_two frame].size.width, [text_two frame].size.height)];
	[date setFrame:NSMakeRect([text_two frame].origin.x + [text_two frame].size.width, 18*[table_contents count] + 11, [text frame].size.width, [text frame].size.height)];
	
	[table setFrame:NSMakeRect(10,10,600,18*[table_contents count])];
	
	NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
	[printInfo setHorizontalPagination:NSFitPagination];
	[printInfo setHorizontallyCentered:NO];
	[printInfo setVerticallyCentered:NO];
	[printInfo setLeftMargin:72.0];
	[printInfo setRightMargin:72.0];
	[printInfo setTopMargin:73.0];
	[printInfo setBottomMargin:73.0];
	
	NSPrintOperation *op = [NSPrintOperation printOperationWithView:print_view printInfo:printInfo];
	[op setShowPanels:YES];
	[op runOperationModalForWindow:[[MainWindowController sharedInstance] window] delegate:nil didRunSelector:NULL contextInfo:nil];
}
*/
@end
