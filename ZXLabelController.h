/*
 * Name: 	ZXLabelController.h
 * Project:	Strongbox
 * Created on:	2008-07-30
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
#import "ZXLabelMO.h"

@class ZXLabelMO;

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
}
@property (assign) NSMutableDictionary *usedNames;
@property (retain) ZXLabelMO *noLabel;

//! Sets the name of the label in the notification to avoid conflicts.
/*! 
 This function changes the name of the label in the notification if there is
 a duplicate with existing labels.
 \param aNotification NSNotification containing the new label as object.
 \sa uniqueNewName:
 */
- (void)validatesNewLabelName:(NSNotification *)aNotification;

//! Generates a non-conflicting name from given name
/*! 
 Returns a new name from the given so that no conflict arises inserting a new 
 label with that name. Appends a number after the name if already exists.
 \param newDesiredName String containing the desired name of the label.
 \return Same or modified name depending on if conflict was found. 
 */
- (NSString *)uniqueNewName:(NSString *)newDesiredName;

//! Update the dictionary of used names to reflect current state
/*! 
 Used when change is done on controlled objects. Costly operation, uses fetch in
 CoreData store to retrieve names.
 */
- (void)updateUsedNames;

//! Initialization of the "no-label" object
- (void)setupNoLabelObject;
@end
