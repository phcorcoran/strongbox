/*
    Copyright (C) 2004  Whitney Young

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

/* ReportWindowController */

#if PATATE

#import <Cocoa/Cocoa.h>
//#import "Cashbox.h"

@class WYReportView, WYAccount, WYClickView;
@interface ReportWindowController : NSObject {
	IBOutlet NSWindow *reportWindow;
	IBOutlet WYReportView *reportView;
	IBOutlet WYClickView *reportTextView;
	IBOutlet NSBox *divider;
	IBOutlet NSView *allAccounts;
	IBOutlet NSPopUpButton *select;
	IBOutlet NSPopUpButton *selectTime;
    NSMutableArray *formatted_text_fields;
	
	BOOL showPercents;
	WYLabelSet *labels;
	double total; // Contains the sum of ALL labels totals [totals vFKP:@"self.@sum"]
	NSMutableArray *totals; // contains all separate totals 
}

+ (ReportWindowController *)sharedInstance;
- (void)showWindowForAccount:(WYAccount *)account;

- (IBAction)changeReportType:(id)sender;
- (IBAction)changeDollarPercent:(id)sender;

@end

#endif
