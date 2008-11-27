//
//  ZXAccountController.h
//  Cashbox
//
//  Created by Pierre-Hans on 03/06/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZXNotifications.h"
#import "ZXAccountMO.h"
#import "ZXTransactionController.h"

@interface ZXAccountController : NSArrayController {
	NSMutableDictionary *usedNames;
	IBOutlet ZXTransactionController *transactionController;
}
@property (assign) NSMutableDictionary *usedNames;

- (void)prepareContent;
- (void)updateUsedNames;
- (NSString *)uniqueNewName:(NSString *)newDesiredName;
- (void)updateTotal:(NSNotification *)note;
@end
