//
//  ZXOldCashboxImporter.h
//  Cashbox
//
//  Created by Pierre-Hans on 09/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZXDocument.h"

@class ZXDocument;
@interface ZXOldCashboxImporter : NSOperation {
	IBOutlet ZXDocument *owner;
	NSMutableDictionary *allNewLabels;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSTextField *importationMessage;
	IBOutlet NSWindow *importerWindow;
}

@property(assign) NSMutableDictionary *allNewLabels;
@property NSWindow *importerWindow;

- (void)importLabelsFromFile:(NSString *)path;
- (void)importAccountFromFile:(NSString *)path;

@end
