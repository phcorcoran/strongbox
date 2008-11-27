//
//  ZXToolbarSearchField.h
//  Cashbox
//
//  Created by Pierre-Hans on 11/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ZXToolbarSearchField : NSToolbarItem {
	IBOutlet NSSearchField *customSearchField;
}
- (void)awakeFromNib;
@end
