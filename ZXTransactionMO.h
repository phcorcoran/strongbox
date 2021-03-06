/*
 * Name: 	ZXTransactionMO.h
 * Project:	Strongbox
 * Created on:	2008-03-04
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

//! Transaction managed object
/*!
 Handles basic initialization and notifying for transactions.
 */
@interface ZXTransactionMO : NSManagedObject {
	//! Forward variable for transactionLabel.name
	/*!
	 Some problems where encountered when trying to use a key path somewhere.
	 This solved the problem.
	 */
	IBOutlet NSString *transactionLabelName;
	IBOutlet NSNumber *balance;
}
@property(copy) NSString *transactionLabelName;
@property(retain) NSNumber *balance;
@end
