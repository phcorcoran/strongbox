//
//  ZXConfigWindowDelegate.m
//  Cashbox
//
//  Created by Pierre-Hans on 07/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ZXConfigWindowDelegate.h"


@implementation ZXConfigWindowDelegate
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
	return [owner undoManager];
}
@end
