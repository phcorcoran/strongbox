/*
 * Name: 	ZXAccountMO.h
 * Project:	Strongbox
 * Created on:	2008-07-16
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

//! Account managed object
/*! 
 Prevents duplicate names in accounts. Also manages the balance calculation.
 */
@interface ZXAccountMO : NSManagedObject {
	IBOutlet NSNumber *balance;
}
@property(copy) NSNumber *balance;
//! Sets the name of the account avoiding verification
/*! 
 Verify that no duplicates exist in the controller before using that method.
 \param newName New name for account.
 */
- (void)specialSetName:(NSString *)newName;

//! Recalculate the balance for the account
/*!
 Sets the new balance for the account AND for each transactions.
 */
- (void)recalculateBalance:(NSNotification *)note;
@end
