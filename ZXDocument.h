//
//  MyDocument.h
//  Cashbox
//
//  Created by Pierre-Hans on 02/03/08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZXReportWindowController.h"
#import "ZXAccountController.h"
#import "ZXTransactionController.h"
#import "ZXLabelController.h"
#import "ZXDocumentConfigController.h"
#import "ZXOldCashboxImporter.h"

@class ZXReportWindowController, ZXOldCashboxImporter;
@interface ZXDocument : NSPersistentDocument {
	// Core Data Controllers
	IBOutlet ZXTransactionController *transactionController;
	IBOutlet ZXAccountController *accountController;
	IBOutlet ZXLabelController *labelController;
	IBOutlet ZXDocumentConfigController *documentConfigController;
	
	// Windows
	IBOutlet NSWindow *configSheet;
	IBOutlet NSWindow *cashboxWindow;
	IBOutlet NSPanel *inspectorPanel;
	
	// Importer Stuff
	IBOutlet ZXOldCashboxImporter *oldCashboxImporter;
	NSOperationQueue *operationQueue;
	
	// Misc
	ZXReportWindowController *reportWindowController;
	IBOutlet NSArray *transactionSortDescriptors;
	IBOutlet NSArray *nameSortDescriptors;
}

@property(readwrite, assign) NSWindow *cashboxWindow;
@property(readonly) ZXAccountController *accountController;
@property ZXTransactionController *transactionController;
@property ZXLabelController *labelController;
@property(copy) NSArray *transactionSortDescriptors;
@property(copy) NSArray *nameSortDescriptors;

- (IBAction)toggleInspector:(id)sender;

- (NSArray *)allLabels;

- (IBAction)addTransaction:(id)sender;
- (IBAction)removeTransaction:(id)sender;

- (IBAction)toggleReportWindow:(id)sender;

- (IBAction)raiseConfigSheet:(id)sender;
- (IBAction)endConfigSheet:(id)sender;
- (void)endConfigSheet:(NSWindow *)sender 
	   returnCode:(int)returnCode 
	  contextInfo:(void *)contextInfo;


- (IBAction)raiseImporterSheet:(id)sender;
- (IBAction)endImporterSheet:(id)sender;
- (void)endImporterSheet:(NSWindow *)sender 
	      returnCode:(int)returnCode 
	     contextInfo:(void *)contextInfo;

- (IBAction)importOldCashboxStuff:(id)sender;
@end
