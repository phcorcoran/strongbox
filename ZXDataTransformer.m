/*
 * Name: 	ZXDataTransformer.m
 * Project:	Daemon
 * Created on:	2008-03-13
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

#import "ZXDataTransformer.h"


@implementation ZXDataTransformer
+ (Class)transformedValueClass { return [NSAttributedString class]; }
+ (BOOL)allowsReverseTransformation { return YES; }
- (id)transformedValue:(id)value {
	if(value == nil) return nil;
	return [[[NSAttributedString alloc] initWithRTFD:value 
				      documentAttributes:nil] autorelease];
}
- (id)reverseTransformedValue:(id)value {
	if(value == nil) return nil;
	return [value RTFDFromRange:NSMakeRange(0, [value length]) 
		 documentAttributes:nil];
}
@end
