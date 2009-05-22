/*
 * Name: 	ZXTransactionController.h
 * Project:	Strongbox
 * Created on:	2008-07-09
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

//! General controller code for transactions
/*!
 Manages completion, and posts ZXAccountTotalDidChangeNotification on add/remove.
 */
@interface ZXTransactionController : NSArrayController {
}
//! Delegate method for text completion
/*!
 Checks if aString is a completion.
 \param aString String containing the current description
 \return YES if aString is a completion.
 \sa completionForPrefix:
 */
-(BOOL)isACompletion:(NSString *)aString;
//! Delegate method for text completion
/*!
 Scan through the _arrangedObjects_ That means if a search is in progress, it 
 will not look for names in the rest of the data for completion.
 \param prefix Current prefix needing completion
 \return Completed string
 */
-(NSString *)completionForPrefix:(NSString *)prefix;
@end
