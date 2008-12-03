/*
 * Name: 	ZXPrintTransactionView.h
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
