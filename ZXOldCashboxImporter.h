/*
 * Name: 	ZXOldCashboxImporter.h
 * Project:	Strongbox
 * Created on:	2008-08-09
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

//! Data importer from the old cashbox application
/*! 
 Imports data from the old cashbox application into curren document. Does not 
 overwrite any currently present data, simply adds new accounts and puts
 transactions in them.
 */
@interface ZXOldCashboxImporter : NSObject {
	//! Front-most document
	IBOutlet ZXDocument *owner;
	//! Stores all the new labels
	NSMutableDictionary *allNewLabels;
	
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSTextField *importationMessage;
	IBOutlet NSWindow *importerWindow;
}
@property(assign) NSMutableDictionary *allNewLabels;
@property(assign) NSWindow *importerWindow;

//! Launches the import procedure
- (void)main;
@end
