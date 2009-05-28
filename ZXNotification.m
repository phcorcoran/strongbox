/*
 * Name: 	ZXNotifications.m
 * Project:	Strongbox
 * Created on:	28/05/09
 *
 * Copyright (C) 2009 Pierre-Hans
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

#import "ZXNotification.h"

static BOOL shouldPostNotifications = YES;

@implementation ZXNotification
+ (BOOL)shouldPostNotifications {
	return shouldPostNotifications;
}
+ (void)setShouldPostNotifications:(BOOL)newVal {
	shouldPostNotifications = newVal;
}
+ (void)postNotificationName:(NSString *)name object:(id)object
{
	if(![self shouldPostNotifications]) return;
	[[NSNotificationCenter defaultCenter] postNotificationName:name object:object];
}
+ (void)enqueueNotification:(id)note postingStyle:(NSPostingStyle)style
{
	if(![self shouldPostNotifications]) return;
	[[NSNotificationQueue defaultQueue] enqueueNotification:note postingStyle:style];
}
+ (void)enqueueNotificationName:(NSString *)name object:(id)object postingStyle:(NSPostingStyle)style
{
	id note = [NSNotification notificationWithName:name object:object];
	[self enqueueNotification:note postingStyle:style];
}
@end
