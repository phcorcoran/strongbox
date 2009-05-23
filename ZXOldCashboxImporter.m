/*
 * Name: 	ZXOldCashboxImporter.m
 * Project:	Strongbox
 * Created on:	2008-08-09
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

#import "ZXOldCashboxImporter.h"
#import "ZXDocument.h"
#import "ZXAppController.h"
#import "ZXLabelMO.h"
#import "ZXTransactionMO.h"
#import "ZXAccountMO.h"

static NSString *sharedNoLabelString = @"-";

@interface ZXOldCashboxImporter (Private)
- (void)importLabelsFromFile:(NSString *)path;
- (void)importAccountFromFile:(NSString *)path;
@end

@implementation ZXOldCashboxImporter
@synthesize allNewLabels, importerWindow;

- (id)initWithOwner:(id)newOwner
{
	self = [super init];
	owner = newOwner;
	[NSBundle loadNibNamed:@"CashboxImporter" owner:self];
	[progressIndicator setUsesThreadedAnimation:YES];
	return self;
}

- (void)raiseImporterSheet
{
	[NSApp beginSheet:importerWindow 
	   modalForWindow:[owner strongboxWindow] 
	    modalDelegate:self 
	   didEndSelector:nil 
	      contextInfo:NULL];
}

- (void)endImporterSheet
{
	[importerWindow orderOut:self];
	[NSApp endSheet:importerWindow returnCode:1];
}

- (void)main
{
	NSLog(@"start");
	[self raiseImporterSheet];
	BOOL toRestore = [ZXAppController shouldPostNotifications];
	[ZXAppController setShouldPostNotifications:NO];
	
	NSError *error = nil;
	
	[[owner managedObjectContext] save:&error];
	
	NSManagedObjectContext *importContext = [[NSManagedObjectContext alloc] init];
	NSPersistentStoreCoordinator *coordinator = [[owner managedObjectContext] persistentStoreCoordinator];
	[importContext setPersistentStoreCoordinator:coordinator];
	[importContext setUndoManager:nil];
	moc = importContext;
	
	allNewLabels = [NSMutableDictionary dictionary];
	NSString *labelsPath = [NSString stringWithFormat:@"%@/Library/Application Support/Cashbox/Labels.plist", NSHomeDirectory()];
	NSString *accountsPath = [NSString stringWithFormat:@"%@/Library/Application Support/Cashbox/Accounts/", NSHomeDirectory()];
	
	[self importLabelsFromFile:labelsPath];
	[moc save:&error];
	
	NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager]
					  enumeratorAtPath:accountsPath];
	NSString *pname;
	while (pname = [direnum nextObject]) {
		if ([[pname pathExtension] isEqualToString:@"plist"]) {
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			[self importAccountFromFile:[NSString stringWithFormat:@"%@%@", accountsPath, pname]];
			[moc save:&error];
			[pool release];
		}
	}
	[self endImporterSheet];
	[ZXAppController setShouldPostNotifications:toRestore];
	[moc save:&error];
	[moc release];
	NSLog(@"stop");
}

//! Imports labels from old cashbox app.
/*!
 Updates the progress indicator while doing so.
 */
- (void)importLabelsFromFile:(NSString *)path
{
	NSArray *array = [[NSArray alloc] initWithContentsOfFile:path];
	
	int labelCount = [array count];
	// FIXME: Hard-coded english
	[importationMessage setStringValue:[NSString stringWithFormat:@"Importing Labels... 0 of %d", labelCount]];
	[progressIndicator setMaxValue:labelCount];
	[progressIndicator setDoubleValue:0];
	[importerWindow display];
	[[owner strongboxWindow] display];

	int i = 0;
	for(id label in array) {
		i += 1;
		if(i % 5 == 0) {
			// FIXME: Hard-coded english
			[importationMessage setStringValue:[NSString stringWithFormat:@"Importing Labels... %d of %d", i, labelCount]];
			[progressIndicator setDoubleValue:i];
			[importerWindow display];
			[[owner strongboxWindow] display];
		}
		
		id newLabel = [NSEntityDescription insertNewObjectForEntityForName:@"Label" inManagedObjectContext:moc];
		[newLabel setValue:[label valueForKey:@"Name of Label"] forKey:@"name"];
		
		id tmp = [label valueForKey:@"Normal Text Color of Label"];
		
		NSColor *color = [NSColor colorWithDeviceRed:[[tmp valueForKey:@"Red Component"] doubleValue]
						       green:[[tmp valueForKey:@"Green Component"] doubleValue]
							blue:[[tmp valueForKey:@"Blue Component"] doubleValue] 
						       alpha:[[tmp valueForKey:@"Alpha Component"] doubleValue]];
		[newLabel setValue:color forKey:@"textColor"];
		
		tmp = [label valueForKey:@"Normal Background Color of Label"];
		color = [NSColor colorWithDeviceRed:[[tmp valueForKey:@"Red Component"] doubleValue]
						       green:[[tmp valueForKey:@"Green Component"] doubleValue]
							blue:[[tmp valueForKey:@"Blue Component"] doubleValue] 
						       alpha:[[tmp valueForKey:@"Alpha Component"] doubleValue]];
		[newLabel setValue:color forKey:@"backgroundColor"];
		
		tmp = [label valueForKey:@"Reconciled Text Color of Label"];
		color = [NSColor colorWithDeviceRed:[[tmp valueForKey:@"Red Component"] doubleValue]
					      green:[[tmp valueForKey:@"Green Component"] doubleValue]
					       blue:[[tmp valueForKey:@"Blue Component"] doubleValue] 
					      alpha:[[tmp valueForKey:@"Alpha Component"] doubleValue]];
		[newLabel setValue:color forKey:@"reconciledTextColor"];
		
		tmp = [label valueForKey:@"Reconciled Background Color of Label"];
		color = [NSColor colorWithDeviceRed:[[tmp valueForKey:@"Red Component"] doubleValue]
					      green:[[tmp valueForKey:@"Green Component"] doubleValue]
					       blue:[[tmp valueForKey:@"Blue Component"] doubleValue] 
					      alpha:[[tmp valueForKey:@"Alpha Component"] doubleValue]];
		[newLabel setValue:color forKey:@"reconciledBackgroundColor"];
		
		tmp = [label valueForKey:@"Label Has Border"];
		[newLabel setValue:tmp forKey:@"bordered"];
		
		[allNewLabels setValue:newLabel forKey:[newLabel valueForKey:@"name"]];
	}
	
	id arr;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Label" 
					    inManagedObjectContext:moc]];
	NSError *error = nil;
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name LIKE %@)", sharedNoLabelString];
	[fetchRequest setPredicate:pred];
	arr = [moc executeFetchRequest:fetchRequest error:&error];
	if([arr count] > 0) {
		[allNewLabels setValue:[arr objectAtIndex:0] forKey:sharedNoLabelString];
	}
	[array release];
}

//! Imports the account from old cashbox app.
/*!
 Updates the progress indicator while doing so.
 */
- (void)importAccountFromFile:(NSString *)path
{
	NSDictionary *account = [[NSDictionary alloc] initWithContentsOfFile:path];
	
	id newAccount = [NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:moc];
	[newAccount setValue:[account valueForKey:@"Account Name"] forKey:@"name"];
	
	NSArray *transactions = [account valueForKey:@"Transactions"];
	NSString *accountName = [newAccount valueForKey:@"name"];
	
	NSInteger txCount = [transactions count];
	// FIXME: Hard-coded english
	[importationMessage setStringValue:[NSString stringWithFormat:@"Importing %@ ... 0 of %d transactions", accountName, txCount]];
	[progressIndicator setMaxValue:txCount];
	[progressIndicator setDoubleValue:0];
	[importerWindow display];
	[[owner strongboxWindow] display];
	
	int i = 0;
	for(id transaction in transactions) {
		i += 1;
		if(i % 20 == 0) {
			// FIXME: Hard-coded english
			[importationMessage setStringValue:[NSString stringWithFormat:@"Importing %@ ... %d of %d transactions", accountName, i, txCount]];
			[progressIndicator setDoubleValue:i];
			[importerWindow display];
			[[owner strongboxWindow] display];
		}
		id newTransaction = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:moc];
		[newTransaction setValue:[transaction valueForKey:@"Date Column"] forKey:@"date"];
		[newTransaction setValue:[transaction valueForKey:@"Deposit Column"] forKey:@"deposit"];
		[newTransaction setValue:[transaction valueForKey:@"Withdrawal Column"] forKey:@"withdrawal"];
		[newTransaction setValue:[transaction valueForKey:@"Description Column"] forKey:@"transactionDescription"];
		[newTransaction setValue:[allNewLabels valueForKey:[transaction valueForKey:@"Label"]] forKey:@"transactionLabel"];
		if([transaction valueForKey:@"Label"] == nil) {
			[newTransaction setValue:[allNewLabels valueForKey:sharedNoLabelString] forKey:@"transactionLabel"];
		}
		[newTransaction setValue:newAccount forKey:@"account"];
	}
	
	[progressIndicator setDoubleValue:0];
	[progressIndicator setMaxValue:1];
	[importationMessage setStringValue:@"Importation Message"];
	[importerWindow display];
	[[owner strongboxWindow] display];
	
	//[[owner accountController] setSelectedObjects:[NSArray arrayWithObjects:newAccount, nil]];
	[account release];
}
@end
