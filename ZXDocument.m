/*
 * Name: 	ZXDocument.m
 * Project:	Strongbox
 * Created on:	2008-03-02
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

#import "ZXDocument.h"
#import "NSStringExportAdditions.h"
#import "ZXAccountController.h"
#import "ZXAccountMergeController.h"
#import "ZXDocumentConfigController.h"
#import "ZXLabelController.h"
#import "ZXNotifications.h"
#import "ZXOldCashboxImporter.h"
#import "ZXPrintTransactionView.h"
#import "ZXReportWindowController.h"
#import "ZXTransactionController.h"



@implementation ZXDocument

@synthesize strongboxWindow, accountController, transactionSortDescriptors, nameSortDescriptors, transactionController, labelController, dateFormatter;

- (id)init
{
	self = [super init];
	self.transactionSortDescriptors = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"date" 
										ascending:NO] autorelease]];
	self.nameSortDescriptors = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease]];
	self.dateFormatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%d" 
						     allowNaturalLanguage:NO] autorelease];
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
	[super windowControllerDidLoadNib:windowController];
	[[NSNotificationCenter defaultCenter] postNotificationName:ZXAccountControllerDidLoadNotification object:self];
	id note = [NSNotification notificationWithName:ZXAccountTotalDidChangeNotification object:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:note postingStyle:NSPostWhenIdle];
}

- (NSString *)windowNibName 
{
	return @"ZXDocument";
}

#pragma mark Menu items actions

- (IBAction)addTransaction:(id)sender
{
	[transactionController add:self];
}

- (IBAction)removeTransaction:(id)sender
{
	[transactionController remove:self];
}

#pragma mark Control config window
- (IBAction)raiseConfigSheet:(id)sender
{
	if(!configSheet) {
		[NSBundle loadNibNamed:@"ConfigWindow" owner:self];
	}
	[NSApp beginSheet:configSheet 
	   modalForWindow:[self strongboxWindow] 
	    modalDelegate:self 
	   didEndSelector:nil 
	      contextInfo:NULL];
}

- (IBAction)endConfigSheet:(id)sender
{
	[configSheet orderOut:sender];
	[NSApp endSheet:configSheet returnCode:1];
}

#pragma mark Control merge window
- (IBAction)raiseMergeSheet:(id)sender
{
	mergeController = [[[ZXAccountMergeController alloc] initWithOwner:self] autorelease];
	[mergeController raiseMergeSheet:sender];
}


#pragma mark Control report window
- (IBAction)toggleReportWindow:(id)sender
{
	if(!reportWindowController) {
		reportWindowController = [[ZXReportWindowController alloc] initWithOwner:self];
	}
	[reportWindowController toggleReportWindow:self];
}

#pragma mark Save options
- (IBAction)saveDocument:(id)sender
{
	[documentConfigController updateCurrentAccountName];
	[super saveDocument:sender];
}

// Write the last saved document to preference so it is opened automatically next time.
- (BOOL)writeSafelyToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError **)outError
{
	[[[NSUserDefaultsController sharedUserDefaultsController] values] setValue:[absoluteURL absoluteString] forKey:@"lastFileURL"];
	return [super writeSafelyToURL:absoluteURL ofType:typeName forSaveOperation:saveOperation error:outError];
}

#pragma mark Other stuff

- (NSArray *)allLabels
{
	NSEntityDescription *labelDescription = [NSEntityDescription entityForName:@"Label" 
							    inManagedObjectContext:self.managedObjectContext];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:labelDescription];
	[fetchRequest setSortDescriptors:self.nameSortDescriptors];
	
	NSError *error = nil;
	NSArray *allLabels = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(allLabels == nil) {
		return nil;
	}
	return allLabels;
}

- (void)document:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)contextInfo
{
	return;
}

- (id)managedObjectModel
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"MyModel" ofType:@"mom"];
	NSURL *url = [NSURL fileURLWithPath:path];
	NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
	return [model autorelease];
}

#pragma mark Control importer window
- (IBAction)importOldCashboxStuff:(id)sender
{
	oldCashboxImporter = [[[ZXOldCashboxImporter alloc] initWithOwner:self] autorelease];
	[oldCashboxImporter main];
	for(id account in [accountController valueForKey:@"arrangedObjects"]) {
		[account recalculateBalance:nil];
	}
}

#pragma mark Exporter stuff

- (IBAction)exportToCSV:(id)sender
{
	if(!self.dateFormatter) {
		self.dateFormatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%d" 
							   allowNaturalLanguage:NO] autorelease];
	}
	id name = [NSString stringWithFormat:@"%@ %@", [accountController valueForKeyPath:@"selection.name"], [self.dateFormatter stringFromDate:[NSDate date]]];
	id panel = [NSSavePanel savePanel];
	[panel setRequiredFileType:@"csv"];
	[panel beginSheetForDirectory:nil 
				 file:name
		       modalForWindow:[self strongboxWindow] 
			modalDelegate:self 
		       didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) 
			  contextInfo:NULL];
}

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
	if(returnCode != NSOKButton) return;
	
	NSMutableString *ret = [NSMutableString string];
	id account = [accountController valueForKey:@"selection"];
	[ret appendString:[NSString stringWithFormat:@"%@,%@\n", [account valueForKey:@"name"], [[self.dateFormatter stringFromDate:[NSDate date]] csvExport]]];
	// FIXME: Hard-coded english
	[ret appendString:@"Date,Label,Description,Withdrawal,Deposit,Balance\n"];
	for(id tx in [transactionController valueForKey:@"arrangedObjects"]) {
		NSString *date = [[dateFormatter stringFromDate:[tx valueForKey:@"date"]] csvExport];
		NSString *labelName = [[tx valueForKeyPath:@"transactionLabel.name"] csvExport];
		NSString *description = [[tx valueForKey:@"transactionDescription"] csvExport];
		if(!labelName) labelName = @"\"\"";
		if(!description) description = @"\"\"";
		double withdrawal = [[tx valueForKey:@"withdrawal"] doubleValue];
		double deposit = [[tx valueForKey:@"deposit"] doubleValue];
		double balance = [[tx valueForKey:@"balance"] doubleValue];
		[ret appendString:[NSString stringWithFormat:@"%@,%@,%@,%.2f,%.2f,%.2f\n", 
				   date, labelName, description, withdrawal, deposit, balance]];
	}
	
	[ret writeToURL:[sheet URL] 
	     atomically:NO 
	       encoding:NSUTF8StringEncoding 
		  error:NULL];
}

#pragma mark Printing stuff

- (void)printShowingPrintPanel:(BOOL)flag
{
	NSPrintInfo *printInfo = [self printInfo];
	NSPrintOperation *printOp;
	
	id printView = [[ZXPrintTransactionView alloc] initWithOwner:self];
	
	printOp = [NSPrintOperation printOperationWithView:printView
						 printInfo:printInfo];
	[printOp setShowPanels:flag];
	[self runModalPrintOperation:printOp 
			    delegate:nil 
		      didRunSelector:NULL 
			 contextInfo:NULL];
}

@end
