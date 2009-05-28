/*
 * Name: 	ZXLabelMO.m
 * Project:	Strongbox
 * Created on:	2008-07-30
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

#import "ZXLabelMO.h"
#import "ZXLabelController.h"
#import "ZXNotification.h"


@implementation ZXLabelMO
- (void)awakeFromInsert
{
	[super awakeFromInsert];
	[self setValue:[NSColor blackColor] forKey:@"textColor"];
	[self setValue:[NSColor whiteColor] forKey:@"backgroundColor"];
	id lightGray = [NSColor colorWithCalibratedWhite:0.50 alpha:1];
	id darkGray = [NSColor colorWithCalibratedWhite:0.33 alpha:1];
	[self setValue:darkGray forKey:@"reconciledTextColor"];
	[self setValue:lightGray forKey:@"reconciledBackgroundColor"];
}

//! Controls special cases of key-value changes
/*!
 Prevents the name change of immutable labels (e.g. "no-label" label). Posts a
 ZXLabelNameDidChangeNotification after label name is changed.
 */
- (void)setValue:(id)value forKey:(NSString *)key
{
	// No change is allowed on a immutable label, except to unprotect it.
	if([[self valueForKey:@"isImmutable"] boolValue] && ![key isEqual:@"isImmutable"]) return;
	[super setValue:value forKey:key];
	if([key isEqual:@"name"]) {
		[ZXNotification postNotificationName:ZXLabelDidChangeNotification 
					      object:self];
	} else if([key isEqual:@"obsolete"]) {
		[ZXNotification postNotificationName:ZXTransactionLabelDidChangeNotification
					      object:self];
	}
}
- (void)specialSetName:(NSString *)newName
{
	[super setValue:newName forKey:@"name"];
}

- (NSAttributedString *)coloredName
{
	id attr = [NSDictionary dictionaryWithObjectsAndKeys:[self valueForKey:@"textColor"], NSForegroundColorAttributeName, 
				    [NSFont systemFontOfSize:[NSFont systemFontSize]], NSFontAttributeName, nil];
	id as = [[NSAttributedString alloc] initWithString:[self valueForKey:@"name"] 
						attributes:attr];
	return [as autorelease];
}
@end
