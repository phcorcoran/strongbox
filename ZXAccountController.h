/*
 * Name: 	ZXAccountController.h
 * Project:	Strongbox
 * Created on:	2008-06-03
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

//! General controller code for accounts.
/*!
 Subclass of NSArrayController. Contains all the accounts and ensures no duplicate
 names. Upon insertion of a new object, name is checked for conflict. Will append 
 a non-conflicting number if problems arise, 
 e.g. "New Account" -> "New Account 1".
 */
@interface ZXAccountController : NSArrayController {
	//! Dictionary of used names
	/*! 
	 Variable used to check quickly for conflicts. As account names are 
	 unique, they are stored as dictionary keys, ensuring no duplicates.
	 */
	NSMutableDictionary *usedNames;
	IBOutlet NSString *generalMessage;
}
@property (retain) NSMutableDictionary *usedNames;
@property(assign) NSString *generalMessage;

//! Forward recalculateBalance: message to selected account
- (void)recalculateBalance:(NSNotification *)note;
//! Update message on top of transaction table.
- (void)updateGeneralMessage:(NSNotification *)note;
@end
