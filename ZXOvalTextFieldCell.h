/*
 * Name: 	ZXOvalTextFieldCell.h
 * Project:	Strongbox
 * Created on:	2009-05-22
 *
 * Copyright (C) 2009 Pierre-Hans Corcoran
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

/*
 * Original File WYOvalTextFieldCell.h by Whitney Young
 * Copyright (C) 2004  Whitney Young
 */

#import <Cocoa/Cocoa.h>

@interface NSActionCell(OvalCellAdditions) 
- (BOOL)isOvalCell;
@end

@interface ZXOvalTextFieldCell : NSTextFieldCell {
	NSNumber *shouldDrawOval;
	NSNumber *shouldDrawBorder;
	NSNumber *shouldDrawRightOval;
	NSNumber *shouldDrawLeftOval;
	NSColor *ovalColor;
	NSColor *borderColor;
	float borderWidth;
}
@property(copy) NSNumber *shouldDrawOval;
@property(copy) NSNumber *shouldDrawBorder;
@property(copy) NSNumber *shouldDrawRightOval;
@property(copy) NSNumber *shouldDrawLeftOval;
@property(copy) NSColor *ovalColor;
@property(copy) NSColor *borderColor;
@end
