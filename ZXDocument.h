/*
 * Name: 	ZXDocument.h
 * Project:	Strongbox
 * Created on:	2008-03-02
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

#import <Cocoa/Cocoa.h>

@class ZXReportWindowController, ZXOldCashboxImporter, ZXTransactionController;
@class ZXAccountController, ZXLabelController, ZXDocumentConfigController;

//! Central class of document architecture
/*!
 Handles almost all interface events. Is the owner of all other controllers.
 */
@interface ZXDocument : NSPersistentDocument {
	// Core Data Controllers
	IBOutlet ZXTransactionController *transactionController;
	IBOutlet ZXAccountController *accountController;
	IBOutlet ZXLabelController *labelController;
	IBOutlet ZXDocumentConfigController *documentConfigController;
	
	// Windows
	IBOutlet NSWindow *configSheet;
	IBOutlet NSWindow *strongboxWindow;
	IBOutlet NSDrawer *drawer;
	IBOutlet NSTableView *transactionsView;
	
	// Importer Stuff
	ZXOldCashboxImporter *oldCashboxImporter;
	
	// Misc
	ZXReportWindowController *reportWindowController;
	IBOutlet NSArray *transactionSortDescriptors;
	IBOutlet NSArray *nameSortDescriptors;
	IBOutlet id labelCell;
	
	IBOutlet NSDateFormatter *dateFormatter;
}

@property(readwrite, assign) NSWindow *strongboxWindow;
@property(readonly, assign) ZXAccountController *accountController;
@property(assign) ZXTransactionController *transactionController;
@property(assign) ZXLabelController *labelController;
@property(copy) NSArray *transactionSortDescriptors;
@property(copy) NSArray *nameSortDescriptors;
@property(assign) NSDateFormatter *dateFormatter;

- (NSArray *)allLabels;

- (IBAction)addTransaction:(id)sender;
- (IBAction)removeTransaction:(id)sender;
- (IBAction)addLabel:(id)sender;
- (IBAction)removeLabel:(id)sender;
- (IBAction)addAccount:(id)sender;
- (IBAction)removeAccount:(id)sender;

- (IBAction)toggleReportWindow:(id)sender;

- (IBAction)raiseConfigSheet:(id)sender;
- (IBAction)endConfigSheet:(id)sender;

- (IBAction)raiseMergeSheet:(id)sender;

- (IBAction)importOldCashboxStuff:(id)sender;

- (IBAction)exportToCSV:(id)sender;
- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode  contextInfo:(void  *)contextInfo;
@end
