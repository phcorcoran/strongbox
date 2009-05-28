/*
 * Name: 	ZXDocument.m
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

#import "ZXDocument.h"
#import "NSStringExportAdditions.h"
#import "ZXAccountController.h"
#import "ZXAccountMergeController.h"
#import "ZXDocumentConfigController.h"
#import "ZXLabelController.h"
#import "ZXLabelMO.h"
#import "ZXNotification.h"
#import "ZXOldCashboxImporter.h"
#import "ZXPrintTransactionView.h"
#import "ZXReportWindowController.h"
#import "ZXTransactionController.h"
#import "ZXOvalTextFieldCell.h"
#import "ZXOvalPopUpButtonCell.h"



@implementation ZXDocument

@synthesize strongboxWindow, nameSortDescriptors, transactionSortDescriptors;
@synthesize accountController, transactionController, labelController;
@synthesize dateFormatter;

- (id)init
{
	self = [super init];
	id tmp = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"date" 
								       ascending:NO] autorelease]];
	self.transactionSortDescriptors = tmp;
	tmp = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" 
								    ascending:YES] autorelease]];
	self.nameSortDescriptors = tmp;
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[transactionSortDescriptors release];
	[nameSortDescriptors release];
	[super dealloc];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
	[super windowControllerDidLoadNib:windowController];
	
	[ZXNotification postNotificationName:ZXAccountControllerDidLoadNotification 
				      object:self];
	[ZXNotification enqueueNotificationName:ZXAccountTotalDidChangeNotification 
					 object:self 
				   postingStyle:NSPostWhenIdle];

	[self updateChangeCount:NSChangeCleared];
	
	[transactionsView performSelector:@selector(reloadData)
			       withObject:nil 
			       afterDelay:1.0];
	
	[strongboxWindow setContentBorderThickness:24.0 forEdge:NSMinYEdge];
}

- (NSString *)windowNibName 
{
	return @"ZXDocument";
}

#pragma mark Menu items actions

- (IBAction)addTransaction:(id)sender {	[transactionController add:sender]; }
- (IBAction)removeTransaction:(id)sender { [transactionController remove:sender]; }
- (IBAction)addLabel:(id)sender { [labelController add:sender]; }
- (IBAction)removeLabel:(id)sender { [labelController remove:sender]; }
- (IBAction)addAccount:(id)sender { [accountController add:sender]; }
- (IBAction)removeAccount:(id)sender { [accountController remove:sender]; }

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
	id mergeController = [[[ZXAccountMergeController alloc] initWithOwner:self] autorelease];
	[mergeController main];
	id arr = [accountController arrangedObjects];
	[arr makeObjectsPerformSelector:@selector(recalculateBalance:) withObject:nil];
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
- (BOOL)writeSafelyToURL:(NSURL *)absoluteURL 
		  ofType:(NSString *)typeName 
	forSaveOperation:(NSSaveOperationType)saveOperation 
		   error:(NSError **)outError
{
	id dict = [[NSUserDefaultsController sharedUserDefaultsController] values];
	[dict setValue:[absoluteURL absoluteString] forKey:@"lastFileURL"];
	return [super writeSafelyToURL:absoluteURL 
				ofType:typeName 
		      forSaveOperation:saveOperation 
				 error:outError];
}

#pragma mark Other stuff

- (NSArray *)allLabels
{
	id labelDesc = [NSEntityDescription entityForName:@"Label" 
				   inManagedObjectContext:self.managedObjectContext];
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"obsolete == NO"];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:labelDesc];
	[fetchRequest setSortDescriptors:self.nameSortDescriptors];
	[fetchRequest setPredicate:pred];
	
	NSError *error = nil;
	NSArray *allLabels = [[self managedObjectContext] executeFetchRequest:fetchRequest 
									error:&error];
	if(allLabels == nil) {
		// FIXME: Real error management needed.
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
	id arr = [accountController arrangedObjects];
	[arr makeObjectsPerformSelector:@selector(recalculateBalance:) withObject:nil];
}

#pragma mark Table View Delegate Stuff

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	// Label column
	if([[tableColumn identifier] isEqual:@"label"]) {
		id tx = [[transactionController arrangedObjects] objectAtIndex:row];
		return [labelController popUpCellWithTransaction:tx];
	}
	
	// Amount column
	if([[tableColumn identifier] isEqual:@"amount"]) {
		id cell = [tableColumn dataCellForRow:row];
		id tx = [[transactionController arrangedObjects] objectAtIndex:row];
		NSTextAlignment ta = NSLeftTextAlignment;
		if([[tx valueForKey:@"amount"] doubleValue] < 0) {
			ta = NSRightTextAlignment;
		}
		[cell setAlignment:ta];
		return cell;
	}
	
	// All other columns
	if(tableColumn) return [tableColumn dataCellForRow:row];
	
	// Separator in case tableColumn is nil
	// Might be useful to separate by month
	if(row == 5 && NO) {
		id cell = [[NSButtonCell alloc] init];
		[cell setTitle:@"AAAAAAA"];
		[cell setBordered:NO];
		return [cell autorelease];
	}
	return nil;
}

- (void)tableViewColumnDidMove:(NSNotification *)aNotification {
	[transactionsView setNeedsDisplay:YES];
}

- (void)tableView:(NSTableView *)tableView 
  willDisplayCell:(id)cell 
   forTableColumn:(NSTableColumn*)tableColumn 
	      row:(int)row
{
	if(row >= [[transactionController arrangedObjects] count]) return;
	if(tableColumn == nil) return;
	
	id tx = [[transactionController arrangedObjects] objectAtIndex:row];
	id label = [tx valueForKey:@"transactionLabel"];
	BOOL reconciled = NO; //[tx valueForKey:@"reconciled"];
	BOOL bordered = [[label valueForKey:@"bordered"] boolValue];
	
	NSColor *backgroundColor = nil;
	NSColor *textColor = nil;
	if (reconciled) {
		backgroundColor = [label valueForKey:@"reconciledBackgroundColor"];
		textColor = [label valueForKey:@"reconciledTextColor"];
	} else {
		backgroundColor = [label valueForKey:@"backgroundColor"];
		textColor = [label valueForKey:@"textColor"];
	}
	
	if(!textColor) textColor = [NSColor blackColor];
	if(!backgroundColor) backgroundColor = [NSColor whiteColor];
	
	if ([cell isOvalCell]) {
		[cell setValue:[NSNumber numberWithBool:YES]
			forKey:@"shouldDrawOval"];
		[cell setOvalColor:backgroundColor];
		
		BOOL shouldDrawBorder = NO;
		if (bordered) { 
			[cell setBorderColor:textColor];
			shouldDrawBorder = YES;
		}
		[cell setValue:[NSNumber numberWithBool:shouldDrawBorder]
			forKey:@"shouldDrawBorder"];
		
		NSArray *tableColumns = [tableView tableColumns];
		int curColumn = [tableColumns indexOfObject:tableColumn];
		BOOL shouldDrawLeft = YES, shouldDrawRight = YES;
		if (curColumn - 1 >= 0) {
			id prevCell = [[tableColumns objectAtIndex:curColumn - 1] dataCell];
			if([prevCell isOvalCell]) {
				shouldDrawLeft = NO;
			}
		}
		if (curColumn + 1 < [tableColumns count]) { 
			id nextCell = [[tableColumns objectAtIndex:curColumn + 1] dataCell];
			if([nextCell isOvalCell]) {
				shouldDrawRight = NO;
			}
		}
		[cell setValue:[NSNumber numberWithBool:shouldDrawLeft]
			forKey:@"shouldDrawLeftOval"];
		[cell setValue:[NSNumber numberWithBool:shouldDrawRight]
			forKey:@"shouldDrawRightOval"];
	}
	
	if ([cell respondsToSelector:@selector(selectedItem)] && 
	    [[label valueForKey:@"obsolete"] boolValue]) {
		[cell setEnabled:NO];
	}
}

#pragma mark Exporter stuff

- (IBAction)exportToCSV:(id)sender
{
	id accountName = [accountController valueForKeyPath:@"selection.name"];
	id date = [dateFormatter stringFromDate:[NSDate date]];
	// We make a path, so we don't really want any slashes.
	date = [date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
	id name = [NSString stringWithFormat:@"%@ %@", accountName, date];
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
	// FIXME: Hard-coded english
	[ret appendString:@"Date,Label,Description,Amount,Balance\n"];
	for(id tx in [transactionController valueForKey:@"arrangedObjects"]) {
		NSString *date = [dateFormatter stringFromDate:[tx valueForKey:@"date"]];
		NSString *labelName = [[tx valueForKeyPath:@"transactionLabel.name"] csvExport];
		NSString *description = [[tx valueForKey:@"transactionDescription"] csvExport];
		if(!labelName) labelName = @"\"\"";
		if(!description) description = @"\"\"";
		double amount = [[tx valueForKey:@"amount"] doubleValue];
		double balance = [[tx valueForKey:@"balance"] doubleValue];
		[ret appendString:[NSString stringWithFormat:@"%@,%@,%@,%.2f,%.2f\n", 
				   date, labelName, description, amount, balance]];
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
