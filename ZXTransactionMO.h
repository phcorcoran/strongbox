//
//  ZXTransactionMO.h
//  Cashbox
//
//  Created by Pierre-Hans on 04/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZXLabelController.h"
#import "ZXNotifications.h"


@interface ZXTransactionMO : NSManagedObject {
	IBOutlet NSString *transactionLabelName;
}
@property(copy) NSString *transactionLabelName;
- (NSNumber *)balance;
@end
