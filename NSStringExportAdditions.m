//
//  NSStringExportAdditions.m
//  Cashbox
//
//  Created by Pierre-Hans on 22/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSStringExportAdditions.h"


@implementation NSString (ExportAdditions)
- (NSString *)csvExport
{
	id s = [NSMutableString stringWithString:self];
	[s replaceOccurrencesOfString:@"\"" withString:@"\"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	return [NSString stringWithFormat:@"\"%@\"", s];
}
@end
