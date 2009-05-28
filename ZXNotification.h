/*
 * Name: 	ZXNotifications.h
 * Project:	Strongbox
 * Created on:	2008-06-07
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

static NSString *ZXAccountControllerDidLoadNotification = @"AccountControllerDidLoad";
static NSString *ZXLabelControllerDidLoadNotification = @"LabelControllerDidLoad";
static NSString *ZXAccountNameDidChangeNotification = @"AccountNameDidChange";
static NSString *ZXAccountTotalDidChangeNotification = @"AccountTotalDidChange";
static NSString *ZXActiveAccountDidChangeNotification = @"ActiveAccountDidChange";
static NSString *ZXLabelDidChangeNotification = @"LabelDidChange";
static NSString *ZXTransactionLabelDidChangeNotification = @"TransactionLabelDidChange";
static NSString *ZXTransactionSelectionDidChangeNotification = @"TransactionSelectionDidChange";
static NSString *ZXTransactionViewDidLoadNotification = @"TransactionViewDidLoad";

//! Manage notifications
/*!
 Convenience class to manage notifications. It allows to disable notifications 
 application-wide, without modification to the code.
 */
@interface ZXNotification : NSObject {
}
//! Returns YES if notifications should be posted, NO otherwise.
/*!
 Should almost always return YES, except when during a batch import or batch 
 change of some sort
 \sa setShouldPostNotifications:
 */
+ (BOOL)shouldPostNotifications;
//! Enable or disable notification posting application-wide.
/*!
 It is a good idea to disable notifications during a batch import or something
 similar
 \sa shouldPostNotifications
 */
+ (void)setShouldPostNotifications:(BOOL)newVal;
//! Forward method to +[NSNotificationCenter defaultCenter] if notifications are enabled.
+ (void)postNotificationName:(NSString *)name object:(id)object;
//! Forward method to +[NSNotificationQueue defaultQueue] if notifications are enabled.
+ (void)enqueueNotification:(id)note postingStyle:(NSPostingStyle)style;
//! Convenience method to enqueue notifications
/*!
 Create notification with given name and object and calls enqueueNotification:postingStyle:
 \sa enqueueNotification:postingStyle:
 */
+ (void)enqueueNotificationName:(NSString *)name object:(id)object postingStyle:(NSPostingStyle)style;
@end


