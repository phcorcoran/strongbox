/*
 * Name: 	ZXAppController.m
 * Project:	Cashbox
 * Created on:	2008-03-08
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

#import "ZXAppController.h"

@implementation ZXAppController

// If a document was previously saved, should respond not to open an untitled document
- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"lastFileURL"]) {
		return NO;
	}
	return YES;
}

// Load previously saved document if none is to be loaded
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	ZXDocument *documentOpened = nil;
	if([[[NSDocumentController sharedDocumentController] documents] count] == 0) {
		id fileURLData = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastFileURL"];
		if(fileURLData) {
			NSError *error;
			NSURL *fileURL = [NSURL URLWithString:fileURLData];
			if(fileURL != nil) {
				documentOpened = [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:fileURL display:YES error:&error];
			}
		}
		if(documentOpened == nil) {
			[[NSDocumentController sharedDocumentController] newDocument:self];
		}
	}
}
@end
