/*
 * Name: 	ZXAccountController.h
 * Project:	Cashbox
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
#import "ZXNotifications.h"
#import "ZXAccountMO.h"
#import "ZXTransactionController.h"

@interface ZXAccountController : NSArrayController {
	NSMutableDictionary *usedNames;
//	IBOutlet ZXTransactionController *transactionController;
}
@property (retain) NSMutableDictionary *usedNames;

- (void)prepareContent;
- (void)updateUsedNames;
- (NSString *)uniqueNewName:(NSString *)newDesiredName;
//- (void)updateTotal:(NSNotification *)note;
- (void)recalculateBalance:(NSNotification *)note;
@end
