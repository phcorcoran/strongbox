//
//  ZXTransactionController.h
//  Cashbox
//
//  Created by Pierre-Hans on 09/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZXNotifications.h"


@interface ZXTransactionController : NSArrayController {

}
-(BOOL)isACompletion:(NSString *)aString;
-(NSString *)completionForPrefix:(NSString *)prefix;
@end
