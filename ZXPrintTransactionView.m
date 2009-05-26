/*
 * Name: 	ZXPrintTransactionView.m
 * Project:	Strongbox
 * Created on:	2008-11-30
 *
 * Copyright (C) 2008 Pierre-Hans Corcoran
 *
 * --------------------------------------------------------------------------
 *  This program is  free software;  you can redistribute  it and/or modify it
 *  under the terms of the GNU General Public License (version 2) as published 
 *  by  the  Free Software Foundation.  This  program  is  distributed  in the 
 *  hope  that it will be useful,  but WITHOUT ANY WARRANTY;  without even the 
 *  implied warranty of MERCHANTABILITY  or  FITNESS FOR A PARTICULAR PURPOSE.  
 *  See  the  GNU General Public License  for  more  details.  You should have 
 *  received  a  copy  of  the  GNU General Public License   along  with  this 
 *  program;   if  not,  write  to  the  Free  Software  Foundation,  Inc., 51 
 *  Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 * --------------------------------------------------------------------------
 */

#import "ZXPrintTransactionView.h"
#import "ZXDocument.h"
#import "ZXCurrencyFormatter.h"

@interface ZXPrintTransactionView (Private)
- (NSRect)rectForTransaction:(int)i;
- (int)transactionsPerPage;
@end

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

//! Returns YES. View is from top to bottom.
- (BOOL)isFlipped { return YES; }

//! Calculates the rectangle for a given page
- (NSRect)rectForPage:(int)page
{
	NSRect result;
	result.size = paperSize;
	
	result.origin.y = (page - 1) * paperSize.height;
	result.origin.x = 0.0;
	return result;
}

//! Calculates the number of transactions per page
/*! 
 This calculation is based of hard-coded value of the vertical height for each 
 transaction
 */
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

//! Calculates the required rect for given transaction
/*!
 Given document is normally the currently opened frontmost document
 \param i Position ID of the transaction (e.g. 3rd, 4th, etc).
 \return A rectangle corresponding to the required view.
 */
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
		if(!NSIntersectsRect(r, txRect)) continue;
		
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
		v = [[obj valueForKey:@"amount"] doubleValue];
		if(!(-0.001 < v && v < 0.001)) {
			id amount = [nf stringFromNumber:[obj valueForKey:@"amount"]];
			tmp = NSMakeRect(x, txRect.origin.y, a, txRect.size.height);
			[amount drawWithRect:tmp options:NSLineBreakByTruncatingTail attributes:attributes];
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

- (void)dealloc
{
	[attributes release];
	[centeredStyle release];
	[rightStyle release];
	[super dealloc];
}
@end
