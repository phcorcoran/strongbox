//
//  ZXLabelMO.h
//  Cashbox
//
//  Created by Pierre-Hans on 30/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZXLabelController.h"
#import "ZXNotifications.h"

@interface ZXLabelMO : NSManagedObject {
}
- (void)specialSetName:(NSString *)newName;
@end
