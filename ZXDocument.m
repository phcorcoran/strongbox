//
//  MyDocument.m
//  Cashbox
//
//  Created by Pierre-Hans on 02/03/08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import "ZXDocument.h"

#if PATATE
@implementation NSManagedObject (DEBUG)
- (id)valueForUndefinedKey:(id)key
{
	NSLog(@"self = %@, key = %@", self, key);
}
@end
#endif


@implementation ZXDocument

@synthesize cashboxWindow, accountController, sortDescriptors;

- (id)init
{
	self = [super init];
	if (self != nil) {
		self.sortDescriptors = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"date" 
										ascending:NO] autorelease]];
	}
	return self;
}

- (NSString *)windowNibName 
{
	return @"ZXDocument";
}

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
	[NSApp beginSheet:configSheet modalForWindow:[self cashboxWindow] modalDelegate:self didEndSelector:@selector(endConfigSheet:returnCode:contextInfo:) contextInfo:NULL];
}

- (IBAction)endConfigSheet:(id)sender
{
	[configSheet orderOut:sender];
	[NSApp endSheet:configSheet returnCode:1];
}

- (void)endConfigSheet:(NSWindow *)sender 
	   returnCode:(int)returnCode 
	  contextInfo:(void *)contextInfo
{
	return;
}

#pragma mark Control report window
- (IBAction)showReportWindow:(id)sender
{
	if(!reportWindowController) {
		reportWindowController = [[ZXReportWindowController alloc] initWithOwner:self];
	}
	[reportWindowController showWindow];
}

// Write the last saved document to preference so it is opened automatically next time.
- (BOOL)writeToURL:(NSURL *)absoluteURL
	    ofType:(NSString *)typeName
  forSaveOperation:(NSSaveOperationType)saveOperation
originalContentsURL:(NSURL *)absoluteOriginalContentsURL
	     error:(NSError **)error
{
	[[[NSUserDefaultsController sharedUserDefaultsController] values] setValue:[NSArchiver archivedDataWithRootObject:absoluteOriginalContentsURL] forKey:@"lastFileURL"];
	return [super writeToURL:absoluteURL
			  ofType:typeName
		forSaveOperation:saveOperation
	     originalContentsURL:absoluteOriginalContentsURL
			   error:error];
}

#pragma mark Other stuff

- (NSArray *)allLabels
{
	NSEntityDescription *labelDescription = [NSEntityDescription entityForName:@"Label" 
							    inManagedObjectContext:self.managedObjectContext];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:labelDescription];
	
	NSError *error = nil;
	NSArray *allLabels = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(allLabels == nil) {
//FIXME: What should be done here if fetch request yields nil?
		return nil;
	}
	return allLabels;
}

@end
