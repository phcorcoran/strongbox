//
//  ZXAccountMO.h
//  Cashbox
//
//  Created by Pierre-Hans on 16/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZXCurrencyFormatter.h"
#import "ZXNotifications.h"


@interface ZXAccountMO : NSManagedObject {
}
- (NSString *)total;
- (void)specialSetName:(NSString *)newName;
@end
