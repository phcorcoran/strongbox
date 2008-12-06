/*
 * Name: 	ZXCurrencyFormatter.h
 * Project:	Strongbox
 * Created on:	2008-07-16
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

//! Shared currency formatter
/*! 
 Stores a shared instance of a currency formatter defined in XIB. Let all
 class convert numbers to currency in a consistent fashion.
 */
@interface ZXCurrencyFormatter : NSObject {
	//! Links the class with the XIB formatter
	/*!
	 Customization should be done when handling translation of XIB.
	 */
	IBOutlet NSNumberFormatter *currencyFormatter;
}
//! Returns the shared currency formatter
+ (NSNumberFormatter *)currencyFormatter;
@end
