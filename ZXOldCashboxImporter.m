//
//  ZXOldCashboxImporter.m
//  Cashbox
//
//  Created by Pierre-Hans on 09/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXOldCashboxImporter.h"


@implementation ZXOldCashboxImporter
@synthesize allNewLabels, importerWindow;

- (void)main
{
	allNewLabels = [NSMutableDictionary dictionary];
	NSString *labelsPath = [NSString stringWithFormat:@"%@/Library/Application Support/Cashbox/Labels.plist", NSHomeDirectory()];
	NSString *accountsPath = [NSString stringWithFormat:@"%@/Library/Application Support/Cashbox/Accounts/", NSHomeDirectory()];
	
	[self importLabelsFromFile:labelsPath];
	
	NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager]
					  enumeratorAtPath:accountsPath];
	NSString *pname;
	while (pname = [direnum nextObject])
	{
		if ([[pname pathExtension] isEqualToString:@"plist"])
		{
			[self importAccountFromFile:[NSString stringWithFormat:@"%@%@", accountsPath, pname]];
		}
	}
}

- (void)importLabelsFromFile:(NSString *)path
{
	NSArray *array = [NSArray arrayWithContentsOfFile:path];
	
	NSInteger labelCount = [array count];
	[importationMessage setStringValue:[NSString stringWithFormat:@"Importing Labels... 0 of %d", labelCount]];
	[progressIndicator setMaxValue:labelCount];
	[progressIndicator setDoubleValue:0];
	[importerWindow display];
	
	int i = 0;
	for(id label in array) {
		[importationMessage setStringValue:[NSString stringWithFormat:@"Importing Labels... %d of %d", ++i, labelCount]];
		[progressIndicator setDoubleValue:i];
		[importerWindow display];
		
		id newLabel = [[owner labelController] newObject];
		[newLabel setValue:[label valueForKey:@"Name of Label"] forKey:@"name"];
		
		id normalText = [label valueForKey:@"Normal Text Color of Label"];
		
		NSColor *color = [NSColor colorWithDeviceRed:[[normalText valueForKey:@"Red Component"] doubleValue]
						       green:[[normalText valueForKey:@"Green Component"] doubleValue]
							blue:[[normalText valueForKey:@"Blue Component"] doubleValue] 
						       alpha:[[normalText valueForKey:@"Alpha Component"] doubleValue]];
		[newLabel setValue:color forKey:@"textColor"];
		[allNewLabels setValue:newLabel forKey:[newLabel valueForKey:@"name"]];
	}
	
}

- (void)importAccountFromFile:(NSString *)path
{
	NSDictionary *account = [NSDictionary dictionaryWithContentsOfFile:path];
	
	id newAccount = [[owner accountController] newObject];
	[newAccount setValue:[account valueForKey:@"Account Name"] forKey:@"name"];
	
	NSArray *array = [account valueForKey:@"Transactions"];
	NSString *accountName = [newAccount valueForKey:@"name"];
	
	NSInteger txCount = [array count];
	[importationMessage setStringValue:[NSString stringWithFormat:@"Importing %@ ... 0 of %d transactions", accountName, txCount]];
	[progressIndicator setMaxValue:txCount];
	[progressIndicator setDoubleValue:0];
	[importerWindow display];
	
	int i = 0;
	NSMutableArray *transactions = [account valueForKey:@"Transactions"];
	for(id transaction in transactions) {
		
		[importationMessage setStringValue:[NSString stringWithFormat:@"Importing %@ ... %d of %d transactions", accountName, ++i, txCount]];
		[progressIndicator setDoubleValue:i];
		[importerWindow display];
		
		id newTransaction = [[owner transactionController] newObject];
		[newTransaction setValue:[transaction valueForKey:@"Date Column"] forKey:@"date"];
		[newTransaction setValue:[transaction valueForKey:@"Deposit Column"] forKey:@"deposit"];
		[newTransaction setValue:[transaction valueForKey:@"Withdrawal Column"] forKey:@"withdrawal"];
		[newTransaction setValue:[transaction valueForKey:@"Description Column"] forKey:@"transactionDescription"];
		[newTransaction setValue:[allNewLabels valueForKey:[transaction valueForKey:@"Label"]] forKey:@"transactionLabel"];
		if([transaction valueForKey:@"Label"] == nil) {
			// FIXME: Hard-coded english
			[newTransaction setValue:[allNewLabels valueForKey:@"No Label"] forKey:@"transactionLabel"];
		}
		[newTransaction setValue:newAccount forKey:@"account"];
	}
	
	[progressIndicator setDoubleValue:0];
	[progressIndicator setMaxValue:1];
	[importationMessage setStringValue:@"Importation Message"];
	[importerWindow display];
}
@end