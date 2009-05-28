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
#import "ZXNotification.h"

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
	[self raiseImporterSheet];
	BOOL toRestore = [ZXNotification shouldPostNotifications];
	[ZXNotification setShouldPostNotifications:NO];
	
	NSError *error = nil;
	
	moc = [owner managedObjectContext];
	
	allNewLabels = [NSMutableDictionary dictionary];
	id labelsPath = @"~/Library/Application Support/Cashbox/Labels.plist";
	id accountsPath = @"~/Library/Application Support/Cashbox/Accounts/";
	labelsPath = [labelsPath stringByExpandingTildeInPath];
	accountsPath = [accountsPath stringByExpandingTildeInPath];
	
	[self importLabelsFromFile:labelsPath];
	
	id direnum = [[NSFileManager defaultManager] enumeratorAtPath:accountsPath];
	NSString *pname;
	while(pname = [direnum nextObject]) {
		if ([[pname pathExtension] isEqualToString:@"plist"]) {
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			id path = [NSString stringWithFormat:@"%@/%@", accountsPath, pname];
			[self importAccountFromFile:path];
			[pool release];
		}
	}
	[ZXNotification setShouldPostNotifications:toRestore];
	[owner.accountController setSelectionIndex:0];
	
	// The transactions with no label have a nil transactionLabel property
	// We fix that now before returning
	id txDesc = [NSEntityDescription entityForName:@"Transaction" 
				inManagedObjectContext:owner.managedObjectContext];
	id noLabel = [owner.labelController valueForKey:@"noLabel"];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:txDesc];
	
	error = nil;
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"transactionLabel = nil"];
	[fetchRequest setPredicate:pred];
	id array = [owner.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(array == nil) {
		// FIXME: Do some real error management here.
		NSLog(@"fetch request failed with error: %@", error);
		return;
	}
	for(id tx in array) {
		[tx setValue:noLabel forKey:@"transactionLabel"];
	}

	[self endImporterSheet];
}

//! Imports labels from old cashbox app.
/*!
 Updates the progress indicator while doing so.
 */
- (void)importLabelsFromFile:(NSString *)path
{
	NSArray *array = [[NSArray alloc] initWithContentsOfFile:path];
	if(!array) {
		// FIXME: Real error message needed
		NSLog(@"Could not load labels file at %@.", path);
		return;
	}
	
	int labelCount = [array count];
	// FIXME: Hard-coded english
	id message = [NSString stringWithFormat:@"Importing Labels... 0 of %d", labelCount];
	[importationMessage setStringValue:message];
	[progressIndicator setMaxValue:labelCount];
	[progressIndicator setDoubleValue:0];
	[importerWindow display];
	[[owner strongboxWindow] display];

	int i = 0;
	for(id label in array) {
		i += 1;
		if(i % 5 == 0) {
			// FIXME: Hard-coded english
			message = [NSString stringWithFormat:@"Importing Labels... %d of %d", i, labelCount];
			[importationMessage setStringValue:message];
			[progressIndicator setDoubleValue:i];
			[importerWindow display];
			[[owner strongboxWindow] display];
		}
		
		id newLabel = [NSEntityDescription insertNewObjectForEntityForName:@"Label" 
							    inManagedObjectContext:moc];
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
	[array release];
}

//! Imports the account from old cashbox app.
/*!
 Updates the progress indicator while doing so.
 */
- (void)importAccountFromFile:(NSString *)path
{
	NSDictionary *account = [[NSDictionary alloc] initWithContentsOfFile:path];
	if(!account) {
		// FIXME: Real error message needed
		NSLog(@"Could not load account file at %@.", path);
		return;
	}
	
	id newAccount = [NSEntityDescription insertNewObjectForEntityForName:@"Account" 
						      inManagedObjectContext:moc];
	[newAccount setValue:[account valueForKey:@"Account Name"] forKey:@"name"];
	
	NSArray *transactions = [account valueForKey:@"Transactions"];
	NSString *accountName = [newAccount valueForKey:@"name"];
	
	NSInteger txCount = [transactions count];
	// FIXME: Hard-coded english
	id message = [NSString stringWithFormat:@"Importing %@ ... 0 of %d transactions", accountName, txCount];
	[importationMessage setStringValue:message];
	[progressIndicator setMaxValue:txCount];
	[progressIndicator setDoubleValue:0];
	[importerWindow display];
	[[owner strongboxWindow] display];
	
	int i = 0;
	for(id transaction in transactions) {
		i += 1;
		if(i % 20 == 0) {
			// FIXME: Hard-coded english
			message = [NSString stringWithFormat:@"Importing %@ ... %d of %d transactions", accountName, i, txCount];
			[importationMessage setStringValue:message];
			[progressIndicator setDoubleValue:i];
			[importerWindow display];
			[[owner strongboxWindow] display];
		}
		id newTransaction = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" 
								  inManagedObjectContext:moc];
		[newTransaction setValue:[transaction valueForKey:@"Date Column"] 
				  forKey:@"date"];
		double deposit = [[transaction valueForKey:@"Deposit Column"] doubleValue];
		double withdrawal = [[transaction valueForKey:@"Withdrawal Column"] doubleValue];
		double amount = deposit - withdrawal;
		[newTransaction setValue:[NSNumber numberWithDouble:amount] 
				  forKey:@"amount"];
		[newTransaction setValue:[transaction valueForKey:@"Description Column"] 
				  forKey:@"transactionDescription"];
		[newTransaction setValue:[allNewLabels valueForKey:[transaction valueForKey:@"Label"]] 
				  forKey:@"transactionLabel"];
		[newTransaction setValue:newAccount 
				  forKey:@"account"];
	}
	[account release];
}
@end
