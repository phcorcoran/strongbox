//
//  ZXToolbarAccountPopUpField.h
//  Cashbox
//
//  Created by Pierre-Hans on 03/06/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ZXToolbarAccountPopUpField : NSToolbarItem {
	IBOutlet NSPopUpButton *customPopUp;
}
- (void)awakeFromNib;
@end

