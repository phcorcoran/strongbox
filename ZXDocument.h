//
//  MyDocument.h
//  Cashbox
//
//  Created by Pierre-Hans on 02/03/08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZXReportWindowController.h"

@class ZXReportWindowController;
@interface ZXDocument : NSPersistentDocument {
	IBOutlet NSArrayController *transactionController;
	IBOutlet NSArrayController *accountController;
	IBOutlet NSArrayController *labelController;
	IBOutlet NSWindow *configSheet;
	IBOutlet NSWindow *cashboxWindow;
	ZXReportWindowController *reportWindowController;
	IBOutlet NSArray *sortDescriptors;
}

@property(readwrite, assign) NSWindow *cashboxWindow;
@property(readonly) NSArrayController *accountController;
@property(assign) NSArray *sortDescriptors;

- (NSArray *)allLabels;

- (IBAction)addTransaction:(id)sender;
- (IBAction)removeTransaction:(id)sender;

- (IBAction)showReportWindow:(id)sender;

- (IBAction)raiseConfigSheet:(id)sender;
- (IBAction)endConfigSheet:(id)sender;
- (void)endConfigSheet:(NSWindow *)sender 
	   returnCode:(int)returnCode 
	  contextInfo:(void *)contextInfo;
@end
