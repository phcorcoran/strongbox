//
//  ZXAppController.h
//  Cashbox
//
//  Created by Pierre-Hans on 13/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ZXAppController : NSObject {
}
- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
@end
