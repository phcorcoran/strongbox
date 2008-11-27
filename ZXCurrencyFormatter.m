#import "ZXCurrencyFormatter.h"

static ZXCurrencyFormatter *sharedInstance;

@implementation ZXCurrencyFormatter
+ (ZXCurrencyFormatter *)sharedInstance {
	if(!sharedInstance) {
		sharedInstance = [[ZXCurrencyFormatter alloc] init];
	}
	return sharedInstance;
	
}
+ (NSNumberFormatter *)currencyFormatter
{
	return [[ZXCurrencyFormatter sharedInstance] valueForKey:@"currencyFormatter"];
}

- (void)awakeFromNib
{
	sharedInstance = self;
}
@end
