/*
 * Name: 	ZXDocumentController.h
 * Project:	Strongbox
 * Created on:	2008-07-15
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

@class ZXAccountController;

//! Controller code for DocumentConfig object
/*!
 The document config currently is only useful to store the value of the selected 
 account, so that next time the document is opened this selection remains.
 */
@interface ZXDocumentConfigController : NSObjectController {
	IBOutlet ZXAccountController *accountController;
}
//! Updates the name of the current account name
/*!
 Stores the name of the currently selected account name in the core data
 representation.
 */
- (void)updateCurrentAccountName;
@end
