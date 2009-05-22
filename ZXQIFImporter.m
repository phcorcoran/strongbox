/*
 * Name: 	ZXQIFImporter.m
 * Project:	Strongbox
 * Created on:	2008-12-03
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

#import "ZXQIFImporter.h"


@implementation ZXQIFImporter
#if 0
+ (NSArray *)getAccountsFromQIFFile:(NSString *)path withExistingAccounts:(NSArray *)existing progressWindow:(WYProgressWindow *)progress
{
	enum { LookAccount, LookTransaction, LookNone };
	
	// Put all lines into array
	NSString *contents = [NSString stringWithContentsOfFile:path];
	NSArray *lines = [contents componentsSeparatedByString:@"\r\n"];
	if ([lines count] == 1) { lines = [contents componentsSeparatedByString:@"\n"]; }
	
	int where = LookNone;
	
	int counter;
	for (counter = 0; counter < [lines count]; counter++)
	{
		[progress setProgress:(float)counter / (float)[lines count]];
		NSString *look = [[lines objectAtIndex:counter] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSRange range;
		if ([look length] == 0) { continue; }
		
		// Specify a date
		if ([look length] > 0 && [look characterAtIndex:0] == 'D')
		{
			if (where == LookTransaction)
			{
				if (!gTransaction) { gTransaction = [[WYTransaction alloc] init]; }
				[gTransaction setDate:[NSCalendarDate dateWithString:[look substringFromIndex:1] calendarFormat:@"%m/%d/%Y"]];
			} else if (where == LookAccount)
			{
				if (gAccount)
				{
					[gAccount setAdditionalInfo:[look substringFromIndex:1]];
				}
			}
			continue;
		}
		
		// Specify that a transaction is reconciled?
		if ([look length] > 0 && [look characterAtIndex:0] == 'C')
		{
			if (where == LookTransaction)
			{
				if (!gTransaction) { gTransaction = [[WYTransaction alloc] init]; }
				[gTransaction setReconciled:([look length] > 1)];
			}
			continue;
		}
		
		// Specify an amount of money
		if ([look length] > 0 && [look characterAtIndex:0] == 'T')
		{
			if (where == LookTransaction)
			{
				if (!gTransaction) { gTransaction = [[WYTransaction alloc] init]; }
				// take out "," characters
				NSMutableString *temp = [NSMutableString stringWithString:[look substringFromIndex:1]];
				NSRange loc = [temp rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
				while (loc.location != NSNotFound)
				{
					[temp replaceCharactersInRange:loc withString:@""];
					loc = [temp rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
				}
				// end taking out characters
				double value = [temp doubleValue];
				if (value > 0)
				{
					[gTransaction setDeposit:value];
				} else {
					[gTransaction setWithdrawal:0-value];
				}
			}
			continue;
		}
		
		// Specify check number
		if ([look length] > 0 && [look characterAtIndex:0] == 'N')
		{
			if (where == LookTransaction)
			{
				if (!gTransaction) { gTransaction = [[WYTransaction alloc] init]; }
				[gTransaction setCheckNumber:[look substringFromIndex:1]];
			}
			continue;
		}
		
		// Specify memo (additional information)
		if ([look length] > 0 && [look characterAtIndex:0] == 'M')
		{
			/*if (where == LookTransaction)
			 {
			 if (!gTransaction) { gTransaction = [[WYTransaction alloc] init]; }
			 [gTransaction setAdditionalInformation:[look substringFromIndex:1]];
			 }*/
			continue;
		}
		
		// Specify label
		if ([look length] > 0 && [look characterAtIndex:0] == 'L')
		{
			if (where == LookTransaction)
			{
				if (!gTransaction) { gTransaction = [[WYTransaction alloc] init]; }
				[gTransaction setLabelWithString:[look substringFromIndex:1]];
			}
			continue;
		}
		
		// Specify payee (description)
		if ([look length] > 0 && [look characterAtIndex:0] == 'P')
		{
			if (where == LookTransaction)
			{
				if (!gTransaction) { gTransaction = [[WYTransaction alloc] init]; }
				[gTransaction setDescription:[look substringFromIndex:1]];
			}
			continue;
		}
		
		range = [look rangeOfString:@"!Account"];
		if (range.location == 0) // if we're looking at an account header
		{
			int c2;
			for (c2 = counter; c2 < [lines count]; c2++) // first go through and find the name of the account
			{
				NSString *look2 = [lines objectAtIndex:c2];
				if ([look2 characterAtIndex:0] == 'N') // one we've found the name
				{
					NSString *account_name = [look2 substringFromIndex:1];
					int index = [changed_names_from indexOfObject:account_name]; // see if we've changed the name
					if (index != NSNotFound) // and if we have
					{
						account_name = [changed_names_to objectAtIndex:index]; // use the new name instead
					}
					int j;
					BOOL got = FALSE;
					if (!got)
					{
						for (j = 0; j < [added count]; j++) // and go through the accounts we've created
						{
							if ([[[added objectAtIndex:j] name] isEqualToString:account_name]) // to see if we've created one with that name
							{
								gAccount = [added objectAtIndex:j]; // and if we have, we'll point at that
								got = TRUE;
								[progress setText:[NSString stringWithFormat:@"Importing \"%@\"...", [gAccount name]]];
								break;
							}
						}
					}
					if (!got)
					{
						for (j = 0; j < [merged count]; j++) // and go through the accounts we've merged
						{
							if ([[[merged objectAtIndex:j] name] isEqualToString:account_name]) // to see if we've merged one with that name
							{
								gAccount = [merged objectAtIndex:j]; // and if we have, we'll point at that
								got = TRUE;
								[progress setText:[NSString stringWithFormat:@"Importing \"%@\"...", [gAccount name]]];
								break;
							}
						}
					}
					
					if (!got)
					{
						for (j = 0; j < [existing count]; j++) // and go through the accounts that already exits
						{
							if ([[[existing objectAtIndex:j] name] caseInsensitiveCompare:account_name] == NSOrderedSame) // to see if there's one that already exists
							{
								int result = NSRunAlertPanel(@"Duplicate Name", [NSString stringWithFormat:@"The file you are importing information from already contains an account named %@.  Cashbox can make a new account for you with a similar name or add the transactions from the file to this account.", account_name], @"Use Similar Name", @"Cancel", @"Merge Transactions");
								if (result == -1)
								{
									gAccount = [existing objectAtIndex:j];
									[merged addObject:gAccount];
								} else if (result == 1) {
									
									// begin get an unused name code
									NSString *to = [NSString stringWithFormat:@"%@ Import", account_name];
									BOOL used = FALSE;
									int k, extension = 1;
									for (k = 0; k < [existing count]; k++)
									{
										if ([[[existing objectAtIndex:k] name] isEqualToString:to]) { used = TRUE; }
									}
									for (k = 0; k < [added count]; k++)
									{
										if ([[[added objectAtIndex:k] name] isEqualToString:to]) { used = TRUE; }
									}
									while (used)
									{
										used = FALSE;
										to = [NSString stringWithFormat:@"%@ Import %i", account_name, extension++];
										for (k = 0; k < [existing count]; k++)
										{
											if ([[[existing objectAtIndex:k] name] isEqualToString:to]) { used = TRUE; }
										}
										for (k = 0; k < [added count]; k++)
										{
											if ([[[added objectAtIndex:k] name] isEqualToString:to]) { used = TRUE; }
										}
									}
									// end get an unused name code
									
									[changed_names_from addObject:account_name];
									[changed_names_to addObject:to];
									
									gAccount = [[WYAccount alloc] init];
									[gAccount setName:to];
									[added addObject:gAccount];
									[gAccount release];
								} else {
									[added release];
									return nil;
								}
								got = TRUE;
								[progress setText:[NSString stringWithFormat:@"Importing \"%@\"...", [gAccount name]]];
								break;
							}
						}
					}
					if (!got) // but if we haven't created the account and it didn't exist
					{
						gAccount = [[WYAccount alloc] init]; // we'll make a new one and point at that
						[gAccount setName:account_name];
						[added addObject:gAccount];
						[gAccount release];
						[progress setText:[NSString stringWithFormat:@"Importing \"%@\"...", [gAccount name]]];
					}
					break; // now we can stop looking for the name part
				}
				if ([look2 isEqualToString:@"^"]) // what?  there was no name part
				{
					NSRunAlertPanel(@"Error", @"There was an error reading the QIF file.  Please report the problem at http://wbyoung.ambitiouslemon.com/cashbox/support/", nil, @"OK", nil);
					[added release];
					return nil;
				}
			}
			where = LookAccount;
			continue;
		}
		
		range = [look rangeOfString:@"!Type:"];
		if (range.location == 0)
		{
			if (!gAccount)
			{
				// begin get an unused name code
				NSString *to = [NSString stringWithFormat:@"Import"];
				BOOL used = FALSE;
				int k, extension = 1;
				for (k = 0; k < [existing count]; k++)
				{
					if ([[[existing objectAtIndex:k] name] isEqualToString:to]) { used = TRUE; }
				}
				for (k = 0; k < [added count]; k++)
				{
					if ([[[added objectAtIndex:k] name] isEqualToString:to]) { used = TRUE; }
				}
				while (used)
				{
					used = FALSE;
					to = [NSString stringWithFormat:@"Import %i", extension++];
					for (k = 0; k < [existing count]; k++)
					{
						if ([[[existing objectAtIndex:k] name] isEqualToString:to]) { used = TRUE; }
					}
					for (k = 0; k < [added count]; k++)
					{
						if ([[[added objectAtIndex:k] name] isEqualToString:to]) { used = TRUE; }
					}
				}
				// end get an unused name code
				
				gAccount = [[WYAccount alloc] init];
				[gAccount setName:to];
				[added addObject:gAccount];
				[gAccount release];
				[progress setText:[NSString stringWithFormat:@"Importing \"%@\"...", [gAccount name]]];
			}
			
			// set account type
			
			where = LookTransaction;
			continue;
		}
		
		if ([look length] > 0 && [look characterAtIndex:0] == '^')
		{
			if (where == LookTransaction)
			{
				if (gTransaction && gAccount)
				{
					[gAccount addTransaction:gTransaction];
					[gTransaction release];
					gTransaction = nil;
				}
			}
			continue;
		}
		
	}
	return [added autorelease];
}
#endif
@end
