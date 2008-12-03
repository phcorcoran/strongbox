/*
 * Name: 	ZXTransactionMO.h
 * Project:	Cashbox
 * Created on:	2008-03-04
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
#import "ZXLabelController.h"
#import "ZXNotifications.h"


@interface ZXTransactionMO : NSManagedObject {
	IBOutlet NSString *transactionLabelName;
}
@property(copy) NSString *transactionLabelName;
//- (NSNumber *)balance;
@end
