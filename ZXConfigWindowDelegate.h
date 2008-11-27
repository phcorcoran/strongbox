//
//  ZXConfigWindowDelegate.h
//  Cashbox
//
//  Created by Pierre-Hans on 07/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ZXDocument;
@interface ZXConfigWindowDelegate : NSObject {
	IBOutlet ZXDocument *owner;
}
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window;
@end
