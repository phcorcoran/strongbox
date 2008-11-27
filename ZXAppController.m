//
//  ZXAppController.m
//  Cashbox
//
//  Created by Pierre-Hans on 13/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

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
