//
//  ZXDocumentController.h
//  Cashbox
//
//  Created by Pierre-Hans on 15/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZXNotifications.h"
#import "ZXAccountController.h"


@interface ZXDocumentController : NSObjectController {
	IBOutlet ZXAccountController *accountController;
}
- (void)updateCurrentAccountName;
@end
