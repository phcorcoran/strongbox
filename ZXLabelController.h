/*
 * Name: 	ZXLabelController.h
 * Project:	Strongbox
 * Created on:	2008-07-30
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

#import <Cocoa/Cocoa.h>

@class ZXLabelMO, ZXOvalPopUpButtonCell;

//! General controller code for labels.
/*!
 Subclass of NSArrayController. Contains all the labels, ensures no duplicate
 names and provides a "no-label" label. Upon insertion of a new object, name is
 checked for conflict. Will append a non-conflicting number if problems arise, 
 e.g. "New Label" -> "New Label 1".
 */
@interface ZXLabelController : NSArrayController {
	//! Dictionary of used names
	/*! 
	 Variable used to check quickly for conflicts. As label names are 
	 unique, they are stored as dictionary keys, ensuring no duplicates.
	 */
	NSMutableDictionary *usedNames;
	//! Unique "no-label" label
	/*! 
	 New transactions will automatically be assigned a "no-label" value.
	 The name of this label is actually "-", and is hard-coded.
	 */
	ZXLabelMO *noLabel;
	IBOutlet id owner;
}
@property (retain) NSMutableDictionary *usedNames;
@property (retain) ZXLabelMO *noLabel;
@property(readonly) NSArray *coloredNames;
- (ZXOvalPopUpButtonCell *)popUpCellWithTransaction:(id)label;
@end
