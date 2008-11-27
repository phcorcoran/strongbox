#import <Cocoa/Cocoa.h>

@interface ZXCurrencyFormatter : NSObject {
	IBOutlet NSNumberFormatter *currencyFormatter;
}
+ (NSNumberFormatter *)currencyFormatter;
@end
